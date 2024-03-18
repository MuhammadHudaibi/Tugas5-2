class Todo {
  final int? id;
  final String title;
  final String description;
  final bool isDone;

  Todo({
    this.id,
    required this.title,
    required this.description,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone ? 1 : 0,
    };
  }
}