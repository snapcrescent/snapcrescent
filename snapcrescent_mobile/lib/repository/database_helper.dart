import 'dart:async';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;

class DatabaseHelper {
  static const _dbName = 'snap-crescent.db';
  static const _dbVersion = 20230802;

  

  static final DatabaseHelper _singleton = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _singleton;
  }

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initiateDatabase();
    return _database!;
  }

  _initiateDatabase() async {
    
    var directory = (await getApplicationDocumentsDirectory()).path;
    String path = '$directory/$_dbName';
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database database, int version) {
    database.execute('''
      CREATE TABLE IF NOT EXISTS APP_CONFIG ( 
        CONFIG_KEY TEXT PRIMARY KEY,
        CONFIG_VALUE TEXT NOT NULL
        );
      ''');

    database.execute('''
      CREATE TABLE IF NOT EXISTS ASSET ( 
        ID INTEGER PRIMARY KEY,
        ACTIVE INTEGER,
        THUMBNAIL_ID INTEGER,
        METADATA_ID INTEGER,
        FAVORITE INTEGER,
        ASSET_TYPE INTEGER
        );
      ''');

    database.execute('''
      CREATE TABLE IF NOT EXISTS METADATA ( 
        ID INTEGER PRIMARY KEY,
        CREATION_DATE_TIME INTEGER,
        NAME TEXT,
        INTERNAL_NAME TEXT,
        MIME_TYPE TEXT,
        ORIENTATION INTEGER,
        SIZE INTEGER,
        LOCAL_ASSET_ID TEXT
        );
      ''');

    database.execute('''
      CREATE TABLE IF NOT EXISTS THUMBNAIL (
        ID INTEGER PRIMARY KEY,
        NAME TEXT
        );
      ''');

    database.execute('''
      CREATE TABLE IF NOT EXISTS ALBUM (
        ID INTEGER PRIMARY KEY,
        NAME TEXT,
        PUBLIC_ACCESS INTEGER,
        ALBUM_TYPE INTEGER,
        ALBUM_THUMBNAIL_ID INTEGER
        );
      ''');

      return _onUpgrade(database, version, version);
  }

  Future _onUpgrade(Database database, int oldVersion, int newVersion) async {  
    try {
      database.execute("ALTER TABLE METADATA ADD COLUMN DURATION INTEGER");
      } catch (ex) {
        developer.log("Something went wrong!", error: ex);
      }
  }

  Future<int> save(String tableName, Map<String, dynamic> row) async {
    Database database = await this.database;
    return await database.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> findAll(
    String tableName,
  ) async {
    Database database = await this.database;
    return await database.query(tableName);
  }

  Future<List<Map<String, dynamic>>> findById(String tableName, int id) async {
    Database database = await this.database;
    return await database.query(tableName, where: 'ID = ?', whereArgs: [id]);
  }

  Future<int> update(String tableName, Map<String, dynamic> row) async {
    Database database = await this.database;
    int id = row['ID'];
    return await database
        .update(tableName, row, where: 'ID = ?', whereArgs: [id]);
  }

  Future<int> delete(String tableName, int id) async {
    Database database = await this.database;
    return await database.delete(tableName, where: 'ID = ?', whereArgs: [id]);
  }

  Future<int> deleteAll(String tableName) async {
    Database database = await this.database;
    return await database.delete(tableName);
  }
}
