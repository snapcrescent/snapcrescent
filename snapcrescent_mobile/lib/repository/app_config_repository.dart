import 'package:snapcrescent_mobile/models/app_config.dart';
import 'package:snapcrescent_mobile/repository/base_repository.dart';
import 'package:snapcrescent_mobile/repository/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class AppConfigRepository extends BaseRepository {
  static const _tableName = 'APP_CONFIG';

  static final AppConfigRepository _singleton = AppConfigRepository._internal();

  factory AppConfigRepository() {
    return _singleton;
  }

  AppConfigRepository._internal() : super(_tableName);

  Future<int> saveOrUpdateConfig(AppConfig entity) async {
    AppConfig config = await findByKey(entity.configKey!);

    if (config.configValue == null) {
      return await DatabaseHelper().save(tableName, entity.toMap());
    } else {
      config.configValue = entity.configValue;
      return await updateConfig(config);
    }
  }

  Future<int> updateConfig(AppConfig entity) async {
    Database database = await DatabaseHelper().database;
    return await database.update(tableName, entity.toMap(),
        where: 'CONFIG_KEY = ?', whereArgs: [entity.configKey!]);
  }

  Future<AppConfig> findByKey(String configKey) async {
    Database database = await DatabaseHelper().database;
    final result = await database.rawQuery(
        '''SELECT * from $tableName where CONFIG_KEY = ? ''', [configKey]);

    if (result.length == 1) {
      return AppConfig.fromMap(result.single);
    } else {
      return Future.value(AppConfig());
    }
  }
}
