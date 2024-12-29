import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit.dart';
import '../models/progress.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habits.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        goal_action TEXT NOT NULL,
        goal_count REAL NOT NULL,
        goal_unit TEXT NOT NULL,
        goal_repeat INTEGER NOT NULL,
        goal_repeat_interval TEXT NOT NULL,
        goal_has_expected_end_date INTEGER NOT NULL,
        goal_expected_end_date TEXT,
        progress_type TEXT NOT NULL,
        progress_step REAL NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        value REAL NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits (id)
      )
    ''');
  }

  // CRUD operations for Habit
  Future<int> createHabit(Habit habit) async {
    final db = await instance.database;
    return await db.insert('habits', habit.toMap());
  }

  Future<Habit?> readHabit(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Habit.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Habit>> readAllHabits({bool includeArchived = false}) async {
    final db = await instance.database;
    final where = includeArchived ? null : 'is_archived = 0';
    final result = await db.query('habits', where: where);
    return result.map((map) => Habit.fromMap(map)).toList();
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await instance.database;
    return db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await instance.database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Progress
  Future<int> createProgress(Progress progress) async {
    final db = await instance.database;
    return await db.insert('progress', progress.toMap());
  }

  Future<List<Progress>> readHabitProgress(int habitId) async {
    final db = await instance.database;
    final result = await db.query(
      'progress',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Progress.fromMap(map)).toList();
  }

  Future<void> deleteProgress(int id) async {
    final db = await database;
    await db.delete(
      'progress',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 