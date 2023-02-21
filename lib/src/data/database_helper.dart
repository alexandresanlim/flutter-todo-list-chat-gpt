import 'package:sqflite/sqflite.dart';
import 'package:todo_list_chat_gpt/src/features/category_items/category_item.dart';
import 'package:todo_list_chat_gpt/src/features/todo_list/todo.dart';
import 'dart:io';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'todo_database.db';
  static const _databaseVersion = 1;

  static const columnId = 'id';

  static const columnTitle = 'name';

  static final DatabaseHelper instance = DatabaseHelper._instance();

  static Database? _database;

  DatabaseHelper._instance();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Todo.table}} (
        ${Todo.columnCategoryItemId} INTEGER NOT NULL,
        ${Todo.columnIsDone} INTEGER NOT NULL,
        $columnId INTEGER PRIMARY KEY autoincrement,
        $columnTitle TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${CategoryItem.tableCategory} (
        ${CategoryItem.columnCategoryCategoryId} INTEGER NOT NULL,
        $columnId INTEGER PRIMARY KEY autoincrement,
        $columnTitle TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTask(Todo task) async {
    Database db = await database;
    return await db.insert(Todo.table, task.toMap());
  }

  Future<List<Todo>> getTasks() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(Todo.table);
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<List<Todo>> getTasksByCategoryItemId(int categoryItemId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(Todo.table,
        where: '${Todo.columnCategoryItemId} = ?', whereArgs: [categoryItemId]);
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<int> deleteTasksByCategoryItemId(int categoryItemId) async {
    Database db = await database;
    return await db.delete(Todo.table,
        where: '${Todo.columnCategoryItemId} = ?', whereArgs: [categoryItemId]);
  }

  Future<int> updateTask(Todo task) async {
    Database db = await database;
    return await db.update(Todo.table, task.toMap(),
        where: '$columnId = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete(Todo.table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> insertCategoryItem(CategoryItem task) async {
    Database db = await database;
    return await db.insert(CategoryItem.tableCategory, task.toMap());
  }

  Future<List<CategoryItem>> getCategoryItems() async {
    Database db = await database;
    List<Map<String, dynamic>> maps =
        await db.query(CategoryItem.tableCategory);
    return List.generate(maps.length, (i) {
      return CategoryItem.fromMap(maps[i]);
    });
  }

  Future<List<CategoryItem>> getCategoryItemsByCategoryId(
      int categoryId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(CategoryItem.tableCategory,
        where: '${CategoryItem.columnCategoryCategoryId} = ?',
        whereArgs: [categoryId]);
    return List.generate(maps.length, (i) {
      return CategoryItem.fromMap(maps[i]);
    });
  }

  Future<CategoryItem?> getCategoryItemById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(CategoryItem.tableCategory,
        where: '$columnId = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return CategoryItem.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteCategoryItem(int id) async {
    Database db = await database;
    return await db.delete(CategoryItem.tableCategory,
        where: '$columnId = ?', whereArgs: [id]);
  }
}
