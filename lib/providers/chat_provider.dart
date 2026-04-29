import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mini_fiverr/providers/data_provider.dart';

class ChatProvider extends ChangeNotifier {
  static const List<String> quickReplies = <String>[
    'Hey!',
    'Hi, how are you?',
    'Busy right now, will reply soon',
    'In a meeting, talk later?',
    'Can you share more details?',
    'Sounds good!',
    'Let me check and get back to you',
    'Thanks! Will look into it',
  ];

  static const List<String> _defaultResponses = <String>[
    'Got it, let me look into this',
    'Interesting, tell me more',
    'Okay, I understand. What is the timeline?',
    'Thanks for sharing! What is your budget for this?',
  ];

  bool _isTyping = false;

  bool get isTyping => _isTyping;

  String buildAutoReply(String input) {
    final String msg = input.toLowerCase();
    if (msg.contains('hey') || msg.contains('hi') || msg.contains('hello')) {
      return _pick(<String>['Hey there! How can I help?', 'Hi! What is up?', 'Hello! Thanks for reaching out']);
    }
    if (msg.contains('busy') || msg.contains('meeting') || msg.contains('later')) {
      return _pick(<String>['No worries, take your time!', 'Sure, ping me when free', 'Okay, I will wait for your reply']);
    }
    if (msg.contains('detail') || msg.contains('more')) {
      return _pick(<String>['Sure! So the project is about...', 'Of course, what should I start with?', 'Here is what I have in mind...']);
    }
    if (msg.contains('good') || msg.contains('great') || msg.contains('awesome')) {
      return _pick(<String>['Great! Let us move forward then', 'Awesome, I will get started', 'Perfect, share the next steps']);
    }
    if (msg.contains('thanks')) {
      return _pick(<String>['You are welcome! Let me know if you need anything', 'Appreciate it! Talk soon', 'No problem at all!']);
    }
    return _pick(_defaultResponses);
  }

  Future<void> sendAndSimulate({
    required DataProvider data,
    required String conversationId,
    required String message,
  }) async {
    data.sendMessage(conversationId: conversationId, content: message);
    _isTyping = true;
    notifyListeners();
    await Future<void>.delayed(Duration(seconds: 2 + Random().nextInt(3)));
    _isTyping = false;
    notifyListeners();
    await data.simulateReply(
      conversationId: conversationId,
      reply: buildAutoReply(message),
    );
  }

  String _pick(List<String> values) => values[Random().nextInt(values.length)];
}
