import 'package:sqflite/sqflite.dart';
import 'package:todo_list_chat_gpt/src/todo_list/todo.dart';
import 'dart:io';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = 'todo_database.db';
  static final _databaseVersion = 1;

  static final table = 'tasks';

  static final columnId = 'id';
  static final columnTitle = 'name';
  static final columnIsDone = 'isCompleted';
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
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnIsDone INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertTask(Todo task) async {
    Database db = await database;
    return await db.insert(table, task.toMap());
  }

  Future<List<Todo>> getTasks() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<int> updateTask(Todo task) async {
    Database db = await database;
    return await db.update(table, task.toMap(),
        where: '$columnId = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
