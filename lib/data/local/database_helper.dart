import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        status INTEGER NOT NULL
      )
    ''');
  }

  // --- MÉTODO PARA INSERTAR MUCHAS (API) ---
  Future<void> insertTasks(List<Task> tasks) async {
    final db = await database;
    for (var task in tasks) {
      await db.insert('tasks', {
        'id': task.id,
        'title': task.title,
        'status': task.status,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // --- MÉTODO PARA INSERTAR UNA SOLA (UI) ---
  Future<int> insertSingleTask(String title) async {
    final db = await database;
    return await db.insert('tasks', {
      'title': title,
      'status': 1, // 1 = To Do
    });
  }

  // --- ESTE ES EL QUE TE FALTA: MÉTODO PARA ELIMINAR ---
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // --- MÉTODO PARA OBTENER TODAS ---
  Future<List<Task>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks');
    return result
        .map(
          (json) => Task(
            id: json['id'] as int,
            title: json['title'] as String,
            status: json['status'] as int,
          ),
        )
        .toList();
  }
}
