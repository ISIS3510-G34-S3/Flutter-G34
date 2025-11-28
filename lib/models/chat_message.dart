import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final bool isPending; // To track offline writes

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
    this.isPending = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Handle timestamp that might be null immediately after local write
    final timestamp = data['createdAt'];
    final DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp == null) {
      dateTime = DateTime.now();
    } else {
      dateTime = DateTime.now();
    }

    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      createdAt: dateTime,
      isRead: data['isRead'] ?? false,
      isPending: doc.metadata.hasPendingWrites,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}

