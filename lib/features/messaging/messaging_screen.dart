import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/colors.dart';
import '../../services/chat_service.dart';
import '../../models/chat_conversation.dart';
import 'chat_detail_screen.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key});

  /// Sanitize user ID to be used as a Firestore map key (must match ChatService)
  String _sanitizeKey(String userId) {
    return userId.replaceAll('.', '_').replaceAll('@', '_at_');
  }

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.forestGreen,
        elevation: 0,
      ),
      body: StreamBuilder<List<ChatConversation>>(
        stream: chatService.getUserChatsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = snapshot.data!;

          if (conversations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No messages yet'),
                  Text('Start a chat from an experience!'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              
              final currentUser = FirebaseAuth.instance.currentUser;
              final myUid = currentUser?.uid;
              final myEmail = currentUser?.email;

              // Use participantNames keys (which persist) instead of participants array
              final allParticipantIds = conversation.participantNames.keys.toList();
              
              // Try to find the other user (not me)
              String otherUserId = allParticipantIds.firstWhere(
                (id) => id != myUid && id != myEmail,
                orElse: () => '',
              );
              
              // Handle case where user is chatting with themselves
              if (otherUserId.isEmpty && allParticipantIds.isNotEmpty) {
                otherUserId = allParticipantIds.first;
              }
              
              // Get name from stored participantNames
              String displayName = conversation.participantNames[otherUserId] ?? 'User';
              
              // Add "(You)" suffix if chatting with yourself
              if (otherUserId == myUid || otherUserId == myEmail) {
                displayName = '$displayName (You)';
              }
              
              // Fallback if name not in map
              if (displayName == 'User' && otherUserId.contains('@')) {
                displayName = otherUserId.split('@')[0];
              }

              // Get unread count - check sanitized keys
              int unreadCount = conversation.unreadCounts[_sanitizeKey(myUid ?? '')] ?? 0;
              if (unreadCount == 0 && myEmail != null) {
                unreadCount = conversation.unreadCounts[_sanitizeKey(myEmail)] ?? 0;
              }
              final hasUnread = unreadCount > 0;

              return ListTile(
                    title: Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                        color: hasUnread ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatDate(conversation.lastMessageTime),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (hasUnread)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.lava,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Chat'),
                                content: const Text('Are you sure you want to delete this chat?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      chatService.deleteChat(conversation.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Chat deleted')),
                                      );
                                    },
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            chatId: conversation.id,
                            otherUserName: displayName,
                          ),
                        ),
                      );
                    },
                  );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
