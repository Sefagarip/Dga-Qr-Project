import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ornek_proje/screens/update.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pdfs.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE pdfs(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      url TEXT
    )
    ''');
  }

  Future<int> insertPdf(PdfItem pdf) async {
    final db = await instance.database;
    return await db.insert('pdfs', {'name': pdf.name, 'url': pdf.url});
  }

  Future<List<PdfItem>> getAllPdfs() async {
    final db = await instance.database;
    final result = await db.query('pdfs');
    return result
        .map((json) => PdfItem(
              name: json['name'] as String,
              url: json['url'] as String,
            ))
        .toList();
  }

  Future<int> deletePdf(int id) async {
    final db = await instance.database;
    return await db.delete('pdfs', where: 'id = ?', whereArgs: [id]);
  }
}
