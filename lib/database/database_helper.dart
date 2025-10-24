import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';

class DataBaseHelper {
  static final DataBaseHelper _instance = DataBaseHelper._internal();
  factory DataBaseHelper() => _instance;
  DataBaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'students.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    String sql = '''
      CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        grade TEXT NOT NULL,
        createdAt INTEGER
      )
    ''';
    await db.execute(sql);
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Aquí puedes agregar futuras migraciones de tablas
    }
  }

  Future<int> insertStudent(Student student) async {
    final Database db = await database;
    return await db.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Student>> getAllStudents() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (index) {
      return Student.fromMap(maps[index]);
    });
  }

  Future<Student?> getStudent(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('students', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Student.fromMap(maps.first);
  }

  Future<int> updateStudent(Student student) async {
    final Database db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final Database db = await database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllStudents() async {
    final Database db = await database;
    return await db.delete('students');
  }

  Future<void> closeDatabase() async {
    final Database db = await database;
    await db.close();
  }
}
