class SecurityQuestions {
  static const List<String> defaults = <String>[
    'What is your pet name?',
    'What city were you born in?',
    'What was your first school?',
    'What is your favorite teacher name?',
    'What is your dream city to visit?',
  ];

  static List<Map<String, String>> generatePresetQuestions({String? firstQuestion, String? secondQuestion}) {
    final List<String> selected = <String>[];

    if (firstQuestion != null && firstQuestion.trim().isNotEmpty) {
      selected.add(firstQuestion.trim());
    }
    if (secondQuestion != null &&
        secondQuestion.trim().isNotEmpty &&
        secondQuestion.trim() != firstQuestion?.trim()) {
      selected.add(secondQuestion.trim());
    }

    for (final String question in defaults) {
      if (selected.length >= 2) {
        break;
      }
      if (!selected.contains(question)) {
        selected.add(question);
      }
    }

    return selected.take(2).map((question) => {'question': question, 'answer': ''}).toList();
  }
}