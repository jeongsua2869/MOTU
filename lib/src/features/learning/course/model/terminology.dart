import 'package:motu/src/features/learning/course/model/word.dart';

class Terminology {
  String title;
  String catchphrase;
  Map<String, Word> word;

  Terminology({
    required this.title,
    required this.catchphrase,
    required this.word,
  });

  factory Terminology.fromJson(Map<String, dynamic> json) {
    Map<String, Word> words = {};
    json['word'].forEach((key, value) {
      words[key] = Word.fromJson(value);
    });

    return Terminology(
      title: json['title'],
      catchphrase: json['catchphrase'],
      word: words,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> words = {};
    word.forEach((key, value) {
      words[key] = value.toJson();
    });

    return {
      'title': title,
      'catchphrase': catchphrase,
      'word': words,
    };
  }
}
