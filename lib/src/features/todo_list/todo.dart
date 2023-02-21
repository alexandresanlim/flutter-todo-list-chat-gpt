import '../../data/database_helper.dart';

class Todo {
  final String name;
  bool isCompleted;
  int id;
  int categoryItemId;

  static const table = 'tasks';

  static const columnCategoryItemId = 'categoryItemId';

  static const columnIsDone = 'isCompleted';

  Todo(
      {required this.name,
      this.isCompleted = false,
      this.id = 0,
      required this.categoryItemId});

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      columnCategoryItemId: categoryItemId,
      DatabaseHelper.columnTitle: name,
      columnIsDone: isCompleted ? 1 : 0,
    };
  }

  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map[DatabaseHelper.columnId],
      categoryItemId: map[columnCategoryItemId],
      name: map[DatabaseHelper.columnTitle],
      isCompleted: map[columnIsDone] == 1,
    );
  }
}
