class SecurityQuestionModel {
  const SecurityQuestionModel({required this.question, required this.answer});

  final String question;
  final String answer;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'question': question,
      'answer': answer,
    };
  }

  factory SecurityQuestionModel.fromJson(Map<String, dynamic> json) {
    return SecurityQuestionModel(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }
}
