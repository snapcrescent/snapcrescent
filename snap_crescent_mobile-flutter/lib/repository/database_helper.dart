import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _dbName = 'snap-crescent.db';
  static final _dbVersion = 1;

  // making it singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database == null) {
      _database = await _initiateDatabase();
    }

    return _database!;
  }

  _initiateDatabase() async {
     var externalDirectory = await getExternalStorageDirectory();
    Directory directory = await new Directory('${externalDirectory!.path}/snap').create(recursive: true);
    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database database, int version) {
    database.execute('''
      CREATE TABLE APP_CONFIG ( 
        CONFIG_KEY TEXT PRIMARY KEY,
        CONFIG_VALUE TEXT NOT NULL
        );
      ''');

    database.execute('''
      CREATE TABLE SYNC_INFO ( 
        ID INTEGER PRIMARY KEY,
        VERSION INTEGER NOT NULL,
        CREATION_DATETIME INTEGER,
        LAST_MODIFIED_DATETIME INTEGER,
        ACTIVE INTEGER
        );
      ''');  

    database.execute('''
      CREATE TABLE ASSET ( 
        ID INTEGER PRIMARY KEY,
        VERSION INTEGER NOT NULL,
        CREATION_DATETIME INTEGER,
        LAST_MODIFIED_DATETIME INTEGER,
        ACTIVE INTEGER,
        THUMBNAIL_ID INTEGER,
        METADATA_ID INTEGER,
        FAVORITE INTEGER,
        ASSET_TYPE INTEGER
        );
      ''');

    database.execute('''
      CREATE TABLE METADATA ( 
        ID INTEGER PRIMARY KEY,
        NAME TEXT,
        SIZE TEXT,
        FILE_TYPE_NAME TEXT,
        FILE_TYPE_LONG_NAME TEXT,
        MIME_TYPE TEXT,
        FILE_EXTENSION TEXT,
        MODEL TEXT,
        HEIGHT TEXT,
        WIDTH TEXT,
        ORIENTATION INTEGER,
        FSTOP TEXT,
        LOCATION_ID INTEGER,
        VERSION INTEGER NOT NULL,
        CREATION_DATETIME INTEGER,
        LAST_MODIFIED_DATETIME INTEGER,
        ACTIVE INTEGER
        );
      ''');

    return database.execute('''
      CREATE TABLE THUMBNAIL (
        ID INTEGER PRIMARY KEY,
        VERSION INTEGER NOT NULL,
        CREATION_DATETIME INTEGER,
        LAST_MODIFIED_DATETIME INTEGER,
        ACTIVE INTEGER,
        NAME TEXT
        );
      ''');
  }

  Future<int> save(String tableName, Map<String, dynamic> row) async {
    Database database = await instance.database;
    return await database.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> findAll(
    String tableName,
  ) async {
    Database database = await instance.database;
    return await database.query(tableName);
  }

  Future<List<Map<String, dynamic>>> findById(String tableName, int id) async {
    Database database = await instance.database;
    return await database.query(tableName, where: 'ID = ?', whereArgs: [id]);
  }

  Future<int> update(String tableName, Map<String, dynamic> row) async {
    Database database = await instance.database;
    int id = row['ID'];
    return await database
        .update(tableName, row, where: 'ID = ?', whereArgs: [id]);
  }

  Future<int> delete(String tableName, int id) async {
    Database database = await instance.database;
    return await database.delete(tableName, where: 'ID = ?', whereArgs: [id]);
  }

  Future<int> deleteAll(String tableName) async {
    Database database = await instance.database;
    return await database.delete(tableName);
  }
}
