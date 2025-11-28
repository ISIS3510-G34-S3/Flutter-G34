import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';
import '../models/chat_conversation.dart';

class ChatService {
  ChatService._internal();
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID or throw exception if not logged in
  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  /// Sanitize user ID to be used as a Firestore map key (replace dots and @ symbols)
  String _sanitizeKey(String userId) {
    return userId.replaceAll('.', '_').replaceAll('@', '_at_');
  }

  /// Get or create a chat with another user
  /// Uses a deterministic ID (uid1_uid2) to prevent duplicates and allow re-joining
  Future<String> getOrCreateChat(String otherUserId) async {
    final myUid = _currentUserId;
    final myEmail = _auth.currentUser?.email;
    
    final List<String> uids = [myUid, otherUserId]..sort();
    final String chatId = uids.join('_');

    final chatDocRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatDocRef.get();

    if (chatDoc.exists) {
      // Chat exists. Ensure current user is in participants array (in case they deleted it previously)
      final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
      
      if (!participants.contains(myUid)) {
        await chatDocRef.update({
          'participants': FieldValue.arrayUnion([myUid]),
        });
      }
      return chatId;
    } else {
      // Create new chat - fetch participant names first
      final Map<String, String> participantNames = {};
      final Map<String, int> unreadCounts = {};
      
      // Fetch my name and set unread counts (use sanitized keys)
      final myName = await _fetchUserName(myUid);
      participantNames[myUid] = myName;
      unreadCounts[_sanitizeKey(myUid)] = 0;
      if (myEmail != null) {
        participantNames[myEmail] = myName;
        unreadCounts[_sanitizeKey(myEmail)] = 0;
      }
      
      // Fetch other user's name and set unread counts (use sanitized keys)
      final otherName = await _fetchUserName(otherUserId);
      participantNames[otherUserId] = otherName;
      unreadCounts[_sanitizeKey(otherUserId)] = 0;
      
      await chatDocRef.set({
        'participants': [myUid, otherUserId],
        'participantNames': participantNames,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCounts': unreadCounts,
      });
      return chatId;
    }
  }

  /// Fetch user name by UID or Email
  Future<String> _fetchUserName(String userId) async {
    try {
      // Try direct document lookup
      var doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['displayName'] ?? data?['name'] ?? 'User';
      }

      // If email, query by email field
      if (userId.contains('@')) {
        final query = await _firestore
            .collection('users')
            .where('email', isEqualTo: userId)
            .limit(1)
            .get();
        
        if (query.docs.isNotEmpty) {
          final data = query.docs.first.data();
          return data['displayName'] ?? data['name'] ?? userId.split('@')[0];
        }
        return userId.split('@')[0]; // Fallback to email prefix
      }

      // If UID, try querying by uid field
      final query = await _firestore
          .collection('users')
          .where('uid', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        return data['displayName'] ?? data['name'] ?? 'User';
      }

      return 'User';
    } catch (e) {
      return 'User';
    }
  }

  /// Send a message in a specific chat
  /// Works offline - writes are queued and synced when connection is restored
  Future<void> sendMessage(String chatId, String content) async {
    final myUid = _currentUserId;
    
    if (content.trim().isEmpty) return;

    try {
      // 1. Add message to sub-collection (queued offline via Firestore cache)
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': myUid,
        'content': content.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // 2. Update parent chat document (queued offline, no transaction for offline support)
      // Parse other user ID from chatId (format: uid1_uid2)
      final parts = chatId.split('_');
      String? otherUserIdNullable;
      if (parts.length == 2) {
        otherUserIdNullable = parts[0] == myUid ? parts[1] : parts[0];
      }

      if (otherUserIdNullable == null) return;
      
      final String otherUserId = otherUserIdNullable;

      // Build updates with sanitized keys for unreadCounts (works offline)
      Map<String, dynamic> updates = {
        'lastMessage': content.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'participants': FieldValue.arrayUnion([otherUserId]),
      };

      // Increment unread using sanitized keys (avoids dot notation issue with emails)
      updates['unreadCounts.${_sanitizeKey(otherUserId)}'] = FieldValue.increment(1);

      await _firestore.collection('chats').doc(chatId).update(updates);
    } catch (e) {
      // Offline writes are queued automatically and don't throw errors
      // Errors here typically mean Firestore isn't initialized
      print('Error sending message (will retry when online): $e');
      rethrow;
    }
  }

  /// Stream of messages for a specific chat
  Stream<List<ChatMessage>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true) // Include pending writes detection
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  /// Stream of all chats for the current user
  Stream<List<ChatConversation>> getUserChatsStream() {
    final myUid = _currentUserId;
    final myEmail = _auth.currentUser?.email;

    // Prepare identifiers list with UID and Email if available
    List<String> identifiers = [myUid];
    if (myEmail != null && myEmail.isNotEmpty) {
      identifiers.add(myEmail);
    }
    
    return _firestore
        .collection('chats')
        .where('participants', arrayContainsAny: identifiers)
        .snapshots(includeMetadataChanges: true) // Include pending writes detection
        .map((snapshot) {
      final chats = snapshot.docs
          .map((doc) => ChatConversation.fromFirestore(doc))
          .toList();
          
      // Client-side sorting since Firestore requires an index for where+orderBy on different fields
      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      
      return chats;
    });
  }

  /// Mark messages as read when entering a chat
  Future<void> markChatAsRead(String chatId) async {
    final myUid = _currentUserId;
    final myEmail = _auth.currentUser?.email;

    // Reset unread count for all my identifiers using sanitized keys
    Map<String, dynamic> updates = {
      'unreadCounts.${_sanitizeKey(myUid)}': 0,
    };
    
    if (myEmail != null && myEmail.isNotEmpty) {
      updates['unreadCounts.${_sanitizeKey(myEmail)}'] = 0;
    }

    await _firestore.collection('chats').doc(chatId).update(updates);

    // 2. Mark individual messages as read (optional, can be expensive if many messages)
    // For now, we'll skip marking individual messages to save writes, 
    // relying on the unreadCount in the parent doc for UI badges.
  }

  /// Delete a chat (and its sub-collection messages)
  /// Note: Deleting sub-collections from client SDK is not natively supported in a single operation.
  /// We can either hide it for the user (flag) or delete documents one by one (expensive).
  /// For simplicity, we will hide the chat from the current user's list.
  Future<void> deleteChat(String chatId) async {
    final myUid = _currentUserId;
    final myEmail = _auth.currentUser?.email;

    // Remove current user from participants array (both UID and email if present)
    List<String> toRemove = [myUid];
    if (myEmail != null && myEmail.isNotEmpty) {
      toRemove.add(myEmail);
    }

    await _firestore.collection('chats').doc(chatId).update({
      'participants': FieldValue.arrayRemove(toRemove),
    });
  }
}

