import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageService {
  static Database? _db;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'thai_step_by_step.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE learning_status (
            item_id TEXT PRIMARY KEY,
            module TEXT,
            status TEXT,
            practice_count INTEGER DEFAULT 0,
            updated_at TEXT
          )
        ''');
      },
    );
  }
}
