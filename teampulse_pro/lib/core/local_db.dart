import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDb {
  static late Database _db;

  static Future<void> init() async {
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'teampulse.db'),
      version: 1,
      onCreate: (db, v) => db.execute(
        'CREATE TABLE store (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      ),
    );
  }

  static Future<String?> read(String key) async {
    final rows = await _db.query(
      'store',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  static Future<void> write(String key, String value) => _db.insert('store', {
    'key': key,
    'value': value,
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  static Future<void> delete(String key) =>
      _db.delete('store', where: 'key = ?', whereArgs: [key]);
}
