import 'package:motu/src/features/learning/course/model/quiz_index.dart';

class Quiz {
  String catchphrase;
  Map<String, QuizIndex> index1;
  Map<String, QuizIndex> index2;
  Map<String, QuizIndex> index3;
  Map<String, QuizIndex> index4;
  Map<String, QuizIndex> index5;
  Map<String, QuizIndex> index6;
  Map<String, QuizIndex> index7;
  Map<String, QuizIndex> index8;
  Map<String, QuizIndex> index9;
  Map<String, QuizIndex> index10;

  Quiz({
    required this.catchphrase,
    required this.index1,
    required this.index2,
    required this.index3,
    required this.index4,
    required this.index5,
    required this.index6,
    required this.index7,
    required this.index8,
    required this.index9,
    required this.index10,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    Map<String, QuizIndex> index1 = {};
    json['index1'].forEach((key, value) {
      index1[key] = QuizIndex.fromJson(value);
    });

    Map<String, QuizIndex> index2 = {};
    json['index2'].forEach((key, value) {
      index2[key] = QuizIndex.fromJson(value);
    });

    Map<String, QuizIndex> index3 = {};
    json['index3'].forEach((key, value) {
      index3[key] = QuizIndex.fromJson(value);
    });

    Map<String, QuizIndex> index4 = {};
    json['index4'].forEach((key, value) {
      index4[key] = QuizIndex.fromJson(value);
    });

    Map<String, QuizIndex> index5 = {};
    json['index5'].forEach((key, value) {
      index5[key] = QuizIndex.fromJson(value);
    });

    Map<String, QuizIndex> index6 = {};
    json['index6'].forEach((key, value) {
      index6[key] = QuizIndex.fromJson(value);
    });

    Map<String, QuizIndex> index7 = {};
    json['index7'].forEach((key, value) {
      index7[key] = QuizIndex.fromJson(value);
    });

    Map<String, QuizIndex> index8 = {};
    json['index8'].forEach((key, value) {
      index8[key] = QuizIndex.fromJson(value);
    });

    Map<String, QuizIndex> index9 = {};
    json['index9'].forEach((key, value) {
      index9[key] = QuizIndex.fromJson(value);
    });

    Map<String, QuizIndex> index10 = {};
    json['index10'].forEach((key, value) {
      index10[key] = QuizIndex.fromJson(value);
    });

    return Quiz(
      catchphrase: json['catchphrase'],
      index1: index1,
      index2: index2,
      index3: index3,
      index4: index4,
      index5: index5,
      index6: index6,
      index7: index7,
      index8: index8,
      index9: index9,
      index10: index10,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> index1 = {};
    this.index1.forEach((key, value) {
      index1[key] = value.toJson();
    });

    Map<String, dynamic> index2 = {};
    this.index2.forEach((key, value) {
      index2[key] = value.toJson();
    });

    Map<String, dynamic> index3 = {};
    this.index3.forEach((key, value) {
      index3[key] = value.toJson();
    });

    Map<String, dynamic> index4 = {};
    this.index4.forEach((key, value) {
      index4[key] = value.toJson();
    });

    Map<String, dynamic> index5 = {};
    this.index5.forEach((key, value) {
      index5[key] = value.toJson();
    });

    Map<String, dynamic> index6 = {};
    this.index6.forEach((key, value) {
      index6[key] = value.toJson();
    });

    Map<String, dynamic> index7 = {};
    this.index7.forEach((key, value) {
      index7[key] = value.toJson();
    });

    Map<String, dynamic> index8 = {};
    this.index8.forEach((key, value) {
      index8[key] = value.toJson();
    });

    Map<String, dynamic> index9 = {};
    this.index9.forEach((key, value) {
      index9[key] = value.toJson();
    });

    Map<String, dynamic> index10 = {};
    this.index10.forEach((key, value) {
      index10[key] = value.toJson();
    });

    return {
      'catchphrase': catchphrase,
      'index1': index1,
      'index2': index2,
      'index3': index3,
      'index4': index4,
      'index5': index5,
      'index6': index6,
      'index7': index7,
      'index8': index8,
      'index9': index9,
      'index10': index10,
    };
  }
}
