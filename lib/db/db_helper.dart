import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/attendee.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'attendance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE attendees(
            id TEXT PRIMARY KEY,
            name TEXT,
            checkedIn INTEGER,
            checkedInAt TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertOrUpdateAttendee(Attendee a) async {
    final db = await database;
    await db.insert(
      'attendees',
      a.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Attendee?> getAttendeeById(String id) async {
    final db = await database;
    final maps = await db.query('attendees', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Attendee.fromMap(maps.first);
    return null;
  }

  Future<List<Attendee>> getAllAttendees() async {
    final db = await database;
    final maps = await db.query('attendees', orderBy: 'checkedIn DESC');
    return maps.map((m) => Attendee.fromMap(m)).toList();
  }
}
