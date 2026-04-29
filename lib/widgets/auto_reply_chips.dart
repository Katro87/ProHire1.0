import 'package:flutter/material.dart';
import 'package:mini_fiverr/providers/chat_provider.dart';
import 'package:mini_fiverr/utils/theme.dart';

class AutoReplyChips extends StatelessWidget {
  const AutoReplyChips({super.key, required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ChatProvider.quickReplies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, int index) {
          final String text = ChatProvider.quickReplies[index];
          return GestureDetector(
            onTap: () => onTap(text),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
          );
        },
      ),
    );
  }
}
