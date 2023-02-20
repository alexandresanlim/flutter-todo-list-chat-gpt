import '../../data/database_helper.dart';

class CategoryItem {
  final String title;
  final int id;
  final int categoryId;

  static const columnCategoryCategoryId = 'categoryId';

  static const tableCategory = 'categoryItem';

  CategoryItem(
      {required this.title, required this.id, required this.categoryId});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': title, columnCategoryCategoryId: categoryId};
  }

  static CategoryItem fromMap(Map<String, dynamic> map) {
    return CategoryItem(
        id: map['id'],
        title: map['name'],
        categoryId: map[columnCategoryCategoryId]);
  }
}
