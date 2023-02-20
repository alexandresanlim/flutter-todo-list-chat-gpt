class Todo {
  final String name;
  bool isCompleted;
  int id;
  int categoryItemId;

  Todo(
      {required this.name,
      this.isCompleted = false,
      this.id = 0,
      required this.categoryItemId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryItemId': categoryItemId,
      'name': name,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      categoryItemId: map['categoryItemId'],
      name: map['name'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
