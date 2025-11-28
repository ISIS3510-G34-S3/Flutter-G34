import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversation {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCounts;
  final Map<String, String> participantNames; // New field

  ChatConversation({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCounts,
    required this.participantNames,
  });

  factory ChatConversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Handle timestamp
    final timestamp = data['lastMessageTime'];
    final DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      dateTime = DateTime.now();
    }

    // Handle unread counts map
    Map<String, int> counts = {};
    if (data['unreadCounts'] != null) {
      final map = data['unreadCounts'] as Map<String, dynamic>;
      map.forEach((key, value) {
        counts[key] = value is int ? value : 0;
      });
    }

    // Handle participant names map
    Map<String, String> names = {};
    if (data['participantNames'] != null) {
      final map = data['participantNames'] as Map<String, dynamic>;
      map.forEach((key, value) {
        names[key] = value?.toString() ?? 'User';
      });
    }

    return ChatConversation(
      id: doc.id,
      participantIds: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: dateTime,
      unreadCounts: counts,
      participantNames: names,
    );
  }
}

