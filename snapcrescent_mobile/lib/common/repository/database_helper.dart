import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:sqlite_async/sqlite3.dart';

import 'package:sqlite_async/sqlite_async.dart';

class DatabaseHelper {
  static const _dbName = 'snap-crescent.db';
  static const _dbVersion = 20231103;

  

  static final DatabaseHelper _singleton = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _singleton;
  }

  DatabaseHelper._internal() ;

  SqliteDatabase ? _database;

  Future<SqliteDatabase> get database async {
    _database ??= await _initiateDatabase();
    return _database!;
  }

  final migrations = SqliteMigrations()
  ..add(SqliteMigration(_dbVersion, (tx) async {
    
    await tx.execute('''
      CREATE TABLE IF NOT EXISTS ASSET ( 
        ID INTEGER PRIMARY KEY,
        ACTIVE INTEGER,
        THUMBNAIL_ID INTEGER,
        METADATA_ID INTEGER,
        FAVORITE INTEGER,
        ASSET_TYPE INTEGER
        );
      ''');

    await tx.execute('''CREATE INDEX IDX_ASSET_ID ON ASSET (ID);''');


    await tx.execute('''
      CREATE TABLE IF NOT EXISTS METADATA ( 
        ID INTEGER PRIMARY KEY,
        CREATION_DATE_TIME INTEGER,
        NAME TEXT,
        INTERNAL_NAME TEXT,
        MIME_TYPE TEXT,
        ORIENTATION INTEGER,
        DURATION INTEGER,
        SIZE INTEGER,
        LOCAL_ASSET_ID TEXT
        );
      
      ''');
    
    await tx.execute('''CREATE INDEX IDX_METADATA_ID ON METADATA (ID);''');

    await tx.execute('''
      CREATE TABLE IF NOT EXISTS THUMBNAIL (
        ID INTEGER PRIMARY KEY,
        NAME TEXT
        );
      
      ''');
    
    await tx.execute('''CREATE INDEX IDX_THUMBNAIL_ID ON THUMBNAIL (ID);''');

   await tx.execute('''
      CREATE TABLE IF NOT EXISTS ALBUM (
        ID TEXT PRIMARY KEY,
        NAME TEXT,
        PUBLIC_ACCESS INTEGER,
        ALBUM_TYPE INTEGER,
        ALBUM_THUMBNAIL_ID INTEGER
        );
      
      ''');

    await tx.execute('''CREATE INDEX IDX_ALBUM_ID ON ALBUM (ID);''');

    await tx.execute('''
      CREATE TABLE IF NOT EXISTS LOCAL_ASSET ( 
        ID INTEGER PRIMARY KEY,
        LOCAL_ASSET_ID TEXT,
        LOCAL_ALBUM_ID TEXT,
        CREATION_DATE_TIME INTEGER,
        SYNCED_TO_SERVER INTEGER,
        );
      ''');

    await tx.execute('''CREATE INDEX IDX_LOCAL_ASSET_ID ON LOCAL_ASSET (ID);''');
    await tx.execute('''CREATE INDEX IDX_LOCAL_ASSET_LOCAL_ASSET_ID ON LOCAL_ASSET (LOCAL_ASSET_ID);''');
    await tx.execute('''CREATE INDEX IDX_LOCAL_ASSET_LOCAL_ALBUM_ID ON LOCAL_ASSET (LOCAL_ALBUM_ID);''');
    
  }));

  _initiateDatabase() async {
    
    var directory = (await getApplicationDocumentsDirectory()).path;
    String path = '$directory/$_dbName';
    final db = SqliteDatabase(path: path);
    await migrations.migrate(db);
    return db;
  }

  Future<List<Row>> getAll(String query, List<Object?> arguments) async {

    SqliteDatabase database = await this.database;
    return await database.getAll(query, arguments);
  }

  Future<Row?> get(String query, List<Object?> arguments) async {

    SqliteDatabase database = await this.database;
    return await database.getOptional(query, arguments);
  }


  Future<void> save(String tableName, Map<String, dynamic> row) async {
    SqliteDatabase database = await this.database;

    String valueString = row.values.join(",");
    List<String> values = valueString.split(",");
    
    String statement = _getCreateStatement(tableName, row, false);
    await database.execute(statement, values);
  }

  Future<void> saveAll(String tableName, List<Map<String, dynamic>> rows) async {

    if(rows.isEmpty) {
      return;
    }

    SqliteDatabase database = await this.database;

    var buffer = StringBuffer();
    for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      Map<String, dynamic> row = rows.elementAt(rowIndex);

      if (buffer.isNotEmpty) {
        buffer.write(",\n");
      }
      buffer.write("(");

      for (int columnIndex = 0; columnIndex < row.values.length; columnIndex++) {
        if(row.values.elementAt(columnIndex) != null) {
          buffer.write("'");
          buffer.write(row.values.elementAt(columnIndex));
          buffer.write("'");
        } else {
          buffer.write('NULL');
        }
        if(columnIndex < row.values.length - 1) {
            buffer.write(",");
        }
      }

      buffer.write(")");
    }
    
    String statement = '''${_getCreateStatement(tableName, rows[0], true)} VALUES ${buffer.toString()}''';
    await database.execute(statement);
  }

  String _getCreateStatement(String tableName, Map<String, dynamic> row, bool isBulkInsert) {
      String paramters = '';
    
      if(isBulkInsert == false) {
        for (int index = 0; index < row.keys.length; index++) {
          paramters = '''$paramters?''';

          if(index < row.keys.length - 1) {
              paramters = '''$paramters,''';  
          }
        }
      }
      
      
      return '''INSERT INTO $tableName(${row.keys.join(',')}) ${isBulkInsert == false ? '''VALUES ($paramters)''' : '' }''';
  }

  Future<List<Row>> findAll(
    String tableName,
  ) async {
    SqliteDatabase database = await this.database;
    return await database.getAll('''SELECT * from $tableName''');
  }

  Future<Row?> findById(String tableName, int id) async {
    SqliteDatabase database = await this.database;
    return await database.getOptional('''SELECT * FROM $tableName WHERE ID = ?''' , [id]);
  }

  Future<void> update(String tableName, Map<String, dynamic> row, String where, String whereArgs) async {
    SqliteDatabase database = await this.database;

    String columns = '';
    
    for (int index = 0; index < row.keys.length; index++) {
      columns = '''$columns${row.keys.elementAt(index)}=?''';

      if(index < row.keys.length - 1) {
          columns = '''$columns,''';  
      }
    }

    List<dynamic> values = [];
    for (int columnIndex = 0; columnIndex < row.values.length; columnIndex++) {
        if(row.values.elementAt(columnIndex) != null) {
            values.add(row.values.elementAt(columnIndex));
        } else {
            values.add(null);
        }
    }

    values.add(whereArgs);
    
    String statement = '''UPDATE $tableName SET $columns WHERE $where''';
    await database.execute(statement, values);
  }

  Future<ResultSet> delete(String tableName, int id) async {
    SqliteDatabase database = await this.database;
    return await database.execute('''DELETE FROM $tableName WHERE ID ?''' , [id]);
  }

  Future<ResultSet> deleteAll(String tableName) async {
    SqliteDatabase database = await this.database;
    return await database.execute('''DELETE FROM $tableName''');
  }
}
