class Status {
  final String title;
  final String description;
  final String type;
  final String stage;
  final bool completed;

  Status({
    required this.title,
    required this.description,
    required this.type,
    required this.stage,
    required this.completed,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      title: json['title'],
      description: json['description'],
      type: json['type'],
      stage: json['stage'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'stage': stage,
      'completed': completed,
    };
  }

  static Status defaultStatus() {
    return Status(
      title: '',
      description: '',
      type: '',
      stage: '',
      completed: false,
    );
  }
}
