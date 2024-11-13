import 'package:intl/intl.dart';

class StockNews {
  final String title;
  final String content;
  final String imageURL;
  final DateTime date;
  bool isRead = false;

  StockNews({
    required this.title,
    required this.content,
    required this.imageURL,
    required this.date,
    this.isRead = false,
  });

  factory StockNews.fromList(List<dynamic> data) {
    return StockNews(
      date: data[0] is DateTime
          ? data[0]
          : DateFormat('yyyy.M.d').parse(data[0].toString()),
      title: data[1].toString(),
      content: data[2].toString(),
      imageURL: data[3].toString(),
      isRead: false,
    );
  }

  // JSON에서 객체 생성
  factory StockNews.fromJson(Map<String, dynamic> json) {
    return StockNews(
      title: json['title'].toString(),
      content: json['content'].toString(),
      imageURL: json['imageURL'].toString(),
      date: DateFormat('yyyy-MM-dd').parse(json['date']),
      isRead: json['isRead'] ?? false,
    );
  }

  // 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'imageURL': imageURL,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'isRead': isRead,
    };
  }
}
