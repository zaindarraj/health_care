import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  late Database database;
  int version = 1;
  Future<Database> getDatabase() async {
    String dbPath = await getDatabasesPath();

    String path = join(dbPath, "app.db");
    database =
        await openDatabase(path, version: version, onCreate: (db, vs) async {
      await db.execute(
          "CREATE TABLE Location (city varchar(25), latitude varchar(25), longitude varchar(25))");
      await db.execute(
          "CREATE TABLE UserC (Email varchar(25), AccountType varchar(10))");
    });
    return database;
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    Database db = await getDatabase();
    return await db.insert(table, values);
  }

  Future<void> delete(String table) async {
    Database db = await getDatabase();
    await db.delete(table);
  }

  Future<List<Map<String, Object?>>> queryLocation() async {
    Database db = await getDatabase();
    return await db.query("Location");
  }

  Future<List<Map<String, Object?>>> queryLocationDetails() async {
    Database db = await getDatabase();
    return await db.query("Location");
  }
}
