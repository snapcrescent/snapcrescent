import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static final _dbName = 'snap-crescent.db'; 
  static final _dbVersion = 2; 
  
  // making it singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    
    if(_database == null) {
      _database = await _initiateDatabase();
    }

    return _database!;
  }

  _initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path,_dbName);
    return await openDatabase(path,version:_dbVersion, onCreate : _onCreate);
  }

  Future _onCreate(Database database,int version) {
    database.execute(
      '''
      CREATE TABLE PHOTO ( 
        ID INTEGER PRIMARY KEY,
        VERSION INTEGER NOT NULL,
        CREATION_DATETIME TEXT,
        LAST_MODIFIED_DATETIME TEXT,
        ACTIVE INTEGER,
        THUMBNAIL_ID INTEGER,
        PHOTO_METADATA_ID INTEGER,
        FAVORITE INTEGER
        );
      ''');

    return database.execute(
      '''
      CREATE TABLE THUMBNAIL (
        ID INTEGER PRIMARY KEY,
        VERSION INTEGER NOT NULL,
        CREATION_DATETIME TEXT,
        LAST_MODIFIED_DATETIME TEXT,
        ACTIVE INTEGER,
        NAME TEXT,
        BASE_64_ENCODED_THUMBNAIL TEXT
        );
      ''');
  }

  Future<int> save(String tableName, Map<String,dynamic> row) async {
      Database database = await instance.database;
      return await database.insert(tableName,row);
  }

  Future<List<Map<String,dynamic>>> findAll(String tableName,) async {
      Database database = await instance.database;
      return await database.query(tableName);
  }

  Future<List<Map<String,dynamic>>> findById(String tableName,int id) async {
      Database database = await instance.database;
      return await database.query(tableName,where: 'ID = ?', whereArgs: [id]);
  }

  Future<int> update(String tableName,Map<String,dynamic> row) async {
      Database database = await instance.database;
      int id = row['ID'];
      return await database.update(tableName,row,where: 'ID = ?', whereArgs: [id]);
  }

  Future<int> delete(String tableName,int id) async {
      Database database = await instance.database;
      return await database.delete(tableName,where: 'ID = ?', whereArgs: [id]);
  }

}