import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import 'package:mini_fiverr/utils/avatar_utils.dart';
import 'package:mini_fiverr/utils/theme.dart';

class ChatRoomScreen extends StatefulWidget {
  final String userName;
  final String userPic;
  final String? receiverId;
  final String? chatId;

  const ChatRoomScreen({super.key, required this.userName, required this.userPic, this.receiverId, this.chatId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _msgController = TextEditingController();
  static const List<String> quickReplies = [
    '👋 Hi! How can I help you?',
    '👍 Sure, I can do that.',
    '⏰ I\'ll get back to you soon.',
    '📅 I\'m available tomorrow.',
    '💰 Let\'s discuss the budget.',
    '📝 Please share more details.',
    '✅ I\'ve started working on it.',
    '🔍 Let me review this.',
    '📎 Can you send the files?',
    '🙏 Thank you for your patience.',
  ];

  String _chatId() {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final otherId = widget.receiverId ?? widget.userName;
    final participants = [currentUid, otherId]..sort();
    return widget.chatId ?? participants.join('_');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markConversationRead());
  }

  Future<void> _markConversationRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final query = await FirebaseFirestore.instance.collection('chats').doc(_chatId()).collection('messages').get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in query.docs) {
      final data = doc.data();
      if (data['senderId'] != currentUser.uid) {
        batch.update(doc.reference, {'isRead': true, 'readAt': FieldValue.serverTimestamp()});
      }
    }
    await batch.commit();
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final chatId = _chatId();
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    // Check if this is the first message
    final msgsSnapshot = await chatRef.collection('messages').limit(1).get();
    final isFirstMessage = msgsSnapshot.docs.isEmpty;

    await chatRef.set({
      'participants': [currentUser.uid, widget.receiverId ?? widget.userName]..sort(),
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await chatRef.collection('messages').add({
      'senderId': currentUser.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _msgController.clear();

    // Auto-reply for first message
    if (isFirstMessage) {
      Future.delayed(const Duration(seconds: 2), () async {
        final autoReplies = [
          "👋 Hi! Thanks for reaching out. I'm currently busy but will get back to you shortly.",
          "Thanks for your message! I'll review your request and respond soon.",
          "Hey there! I'm in the middle of something but I'll reply in a bit.",
          "Got your message! Let me look into this and I'll get back to you.",
          "Hi! I'm available but currently working. I'll respond in detail shortly.",
        ];

        final randomReply = autoReplies[Random().nextInt(autoReplies.length)];

        final participants = [currentUser.uid, widget.receiverId ?? widget.userName]..sort();
        final professionalId = participants.firstWhere((id) => id != currentUser.uid, orElse: () => widget.receiverId ?? currentUser.uid);

        await chatRef.collection('messages').add({
          'senderId': professionalId,
          'text': randomReply,
          'timestamp': FieldValue.serverTimestamp(),
          'isAutoReply': true,
        });

        await chatRef.update({
          'lastMessage': randomReply,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'autoReplySent': true,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please log in to continue.')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                AvatarUtils.buildAvatar(name: widget.userName, imageUrl: widget.userPic, radius: 16),
                Positioned(bottom: 0, right: 0, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Text('Online', style: TextStyle(fontSize: 10, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 54,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: quickReplies.map((reply) => _buildQuickReplyChip(reply)).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_chatId())
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet. Say hello! 👋'));
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == currentUser.uid;
                    final timestamp = message['timestamp'] is Timestamp ? (message['timestamp'] as Timestamp).toDate() : DateTime.now();
                    return _buildChatBubble(message['text'] ?? '', isMe, _formatTime(timestamp));
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildQuickReplyChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => _msgController.text = text);
          _sendMessage();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Text(
            text.length > 25 ? '${text.substring(0, 25)}...' : text,
            style: const TextStyle(fontSize: 12, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(color: isMe ? Colors.white70 : AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _msgController,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: _sendMessage),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
