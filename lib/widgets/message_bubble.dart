import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_fiverr/models/message_model.dart';
import 'package:mini_fiverr/utils/theme.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = message.isSentByMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          );

    return Align(
      alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Column(
          crossAxisAlignment:
              message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: message.isSentByMe
                    ? const LinearGradient(colors: <Color>[Color(0xFF6C5CE7), Color(0xFF8B7CF7)])
                    : null,
                color: message.isSentByMe ? null : AppColors.elevated,
                borderRadius: radius,
              ),
              child: Text(message.content, style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 3),
            Text(
              DateFormat.jm().format(message.timestamp),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
