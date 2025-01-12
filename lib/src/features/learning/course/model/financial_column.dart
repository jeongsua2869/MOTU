class FinancialColumn {
  String title;
  String imageUrl;
  String content;
  List<String> topics;

  FinancialColumn({
    required this.title,
    required this.imageUrl,
    required this.content,
    required this.topics,
  });

  factory FinancialColumn.fromJson(Map<String, dynamic> json) {
    return FinancialColumn(
      title: json['title'],
      imageUrl: json['imageUrl'],
      content: json['content'],
      topics: List<String>.from(json['topics']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'content': content,
      'topics': topics,
    };
  }
}
