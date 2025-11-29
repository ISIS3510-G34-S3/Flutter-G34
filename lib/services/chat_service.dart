import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drift/drift.dart' as drift;
import '../models/chat_message.dart';
import '../models/chat_conversation.dart';
import '../database/app_database.dart';
import 'database_service.dart';

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

      // Check if this is the very first message (count == 1 because we just added it)
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .count()
          .get();

      if (messagesSnapshot.count == 1) {
        trackNewChatStarted();
      }
    } catch (e) {
      // Offline writes are queued automatically and don't throw errors
      // Errors here typically mean Firestore isn't initialized
      print('Error sending message (will retry when online): $e');
      rethrow;
    }
  }

  /// Stream of messages for a specific chat
  Stream<List<ChatMessage>> getMessagesStream(String chatId) async* {
    // 1. Always yield data from Local DB first (Instant load for better UX & Offline support)
    try {
      final database = DatabaseService().database;
      final localMessages = await database.getMessagesForChat(chatId);

      if (localMessages.isNotEmpty) {
        print('✓ Loaded ${localMessages.length} messages from local DB (Displaying instantly)');
        yield localMessages.map((m) => ChatMessage(
          id: m.id,
          senderId: m.senderId,
          content: m.content,
          createdAt: m.createdAt,
          isRead: m.isRead,
          isPending: false,
        )).toList();
      } else {
        // Important: yield empty list if no local messages, so the stream has initial data
        // but we only do this if we are offline, otherwise we wait for network
        // Actually, yielding empty list might clear UI if network is slow, so we just wait.
        // But if offline, we MUST yield something or StreamBuilder hangs.
        // Let's check connectivity or just yield empty if truly nothing.
        // Better pattern: if offline, we rely on this yield.
      }
    } catch (e) {
      print('⚠️ Error loading local messages: $e');
    }

    // 2. Then subscribe to Firestore (Live updates & Sync)
    // If offline, this stream might pause or error. We need to handle that.
    // Using yield* with a Stream that might fail when offline is tricky.
    // We should wrap the firestore stream in a way that it doesn't crash the whole generator.
    
    try {
       yield* _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots(includeMetadataChanges: true) 
          .map((snapshot) {
        final messages = snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList();

        // Sync to local DB (offline persistence)
        if (messages.isNotEmpty) {
          _syncMessagesToLocal(chatId, messages);
        }

        return messages;
      });
    } catch (e) {
       print('⚠️ Firestore stream error (likely offline): $e');
       // If we are offline and here, we already yielded local messages above.
    }
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

  /// ANALYTICS: Track which quick reply is used most often
  Future<void> trackQuickReplyUsage(String replyText) async {
    try {
      final String fieldName = replyText
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .replaceAll(' ', '_');

      await _firestore.collection('analytics').doc('quick_replies').set({
        fieldName: FieldValue.increment(1),
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('⚠️ Failed to track quick reply: $e');
    }
  }

  /// ANALYTICS: Track when a user starts a message from an Experience Detail screen
  Future<void> trackMessageStartFromExperience(String experienceId) async {
    try {
      await _firestore.collection('analytics').doc('experience_message_starts').set({
        experienceId: FieldValue.increment(1),
        'total_starts': FieldValue.increment(1),
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('⚠️ Failed to track message start: $e');
    }
  }

  /// ANALYTICS: Track total new chats started
  Future<void> trackNewChatStarted() async {
    try {
      await _firestore.collection('analytics').doc('messaging_global_usage').set({
        'total_chats_started': FieldValue.increment(1),
        'last_chat_started_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('⚠️ Failed to track new chat started: $e');
    }
  }

  /// Sync messages to local database (Fire and forget)
  Future<void> _syncMessagesToLocal(
      String chatId, List<ChatMessage> messages) async {
    try {
      final database = DatabaseService().database;

      final messageCompanions = messages.map((msg) {
        return MessagesCompanion(
          id: drift.Value(msg.id),
          chatId: drift.Value(chatId),
          senderId: drift.Value(msg.senderId),
          content: drift.Value(msg.content),
          createdAt: drift.Value(msg.createdAt),
          isRead: drift.Value(msg.isRead),
        );
      }).toList();

      await database.upsertMessages(messageCompanions);
      print('✓ Synced ${messages.length} messages for chat $chatId to local DB');
    } catch (e) {
      print('Error syncing messages to local DB: $e');
    }
  }
}
