
import 'package:parkway/Reading.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:async';

const TABLE_NAME = 'reading';

class DatabaseProvider {
  Database database;
  var path;

  Future init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    path = join(directory.path, 'reading.db');

    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      print("created database");
      var sql = """CREATE TABLE $TABLE_NAME(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            date DATE NOT NULL,
            value INTEGER NOT NULL, 
            mobile TEXT NOT NULL, 
            uploaded INTEGER)""";
      
        await db.execute(sql);
    }, onDowngrade: (Database db, int version, int i) async {
// Delete the database
      await deleteDatabase(path);
    });

    print("database created and initialized");

  }
  Future dropDb() async{
    // await database.delete(TABLE_NAME);
  }

  Future<Reading> insertReading(Reading reading) async {
    await init();
    try {
      await database.insert(TABLE_NAME, reading.toMap());
    }on DatabaseException catch(e){
      print(e);
    }
      return reading;
  }

  Future<List<Reading>> queryMeters() async {
    await init();
    List<Reading> readings = [];
    List<Map> maps = await database.query(TABLE_NAME, columns: ['date', 'value', 'mobile'], where: "uploaded !=?", whereArgs: [0]);
    if (maps.length > 0) {
      for (var reading in maps) {
        readings.add(Reading.fromMap(reading));
      }
      return readings;
    }
    return null;
  }

  Future<bool> updateStatus() async{
    await init();
  
  }
}
