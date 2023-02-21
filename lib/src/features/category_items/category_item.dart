import '../../data/database_helper.dart';

class CategoryItem {
  final String title;
  final int id;
  final int categoryId;

  static const columnCategoryCategoryId = 'categoryId';

  static const tableCategory = 'categoryItem';

  bool isExpanded;

  bool isLoading;

  CategoryItem(
      {required this.title,
      required this.id,
      required this.categoryId,
      this.isExpanded = false,
      this.isLoading = false});

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnTitle: title,
      columnCategoryCategoryId: categoryId
    };
  }

  static CategoryItem fromMap(Map<String, dynamic> map) {
    return CategoryItem(
        id: map[DatabaseHelper.columnId],
        title: map[DatabaseHelper.columnTitle],
        categoryId: map[columnCategoryCategoryId]);
  }
}
