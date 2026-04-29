import 'dart:math';

class SecurityQuestions {
  static const List<String> defaults = [
    "What is your mother's maiden name?",
    'What was the name of your first pet?',
    'What city were you born in?',
  ];

  static List<Map<String, String>> generatePresetQuestions({String? firstQuestion, String? secondQuestion}) {
    final choices = [...defaults]..shuffle(Random());
    final selected = <String>{};

    if (firstQuestion != null && firstQuestion.trim().isNotEmpty) {
      selected.add(firstQuestion.trim());
    }
    if (secondQuestion != null && secondQuestion.trim().isNotEmpty) {
      selected.add(secondQuestion.trim());
    }

    for (final question in choices) {
      if (selected.length >= 2) {
        break;
      }
      selected.add(question);
    }

    return selected.take(2).map((question) => {'question': question, 'answer': ''}).toList();
  }
}