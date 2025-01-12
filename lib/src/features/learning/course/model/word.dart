class Word {
  String example;
  String meaning;

  Word({
    required this.example,
    required this.meaning,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      example: json['example'],
      meaning: json['meaning'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'example': example,
      'meaning': meaning,
    };
  }
}
