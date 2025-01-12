class QuizIndex {
  String answer;
  String description;
  String hint;
  List<String> options;
  String question;

  QuizIndex({
    required this.answer,
    required this.description,
    required this.hint,
    required this.options,
    required this.question,
  });

  factory QuizIndex.fromJson(Map<String, dynamic> json) {
    return QuizIndex(
      answer: json['answer'],
      description: json['description'],
      hint: json['hint'],
      options: List<String>.from(json['options']),
      question: json['question'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'description': description,
      'hint': hint,
      'options': options,
      'question': question,
    };
  }
}
