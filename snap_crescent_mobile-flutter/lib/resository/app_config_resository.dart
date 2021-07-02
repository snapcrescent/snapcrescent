import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/resository/base_repository.dart';
import 'package:snap_crescent/resository/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class AppConfigResository extends BaseResository {
  static final _tableName = 'APP_CONFIG';

  AppConfigResository._privateConstructor() : super(_tableName);
  static final AppConfigResository instance =
      AppConfigResository._privateConstructor();

  Future<int> saveOrUpdateConfig(AppConfig entity) async {
    AppConfig config = await findByKey(entity.configkey!);

    if (config.configValue == null) {
      return await DatabaseHelper.instance.save(tableName, entity.toMap());
    } else {
      config.configValue = entity.configValue;
      return await updateConfig(config);
    }
  }

  Future<int> updateConfig(AppConfig entity) async {
    Database database = await DatabaseHelper.instance.database;
    return await database.update(tableName, entity.toMap(),
        where: 'CONFIG_KEY = ?', whereArgs: [entity.configkey!]);
  }

  Future<AppConfig> findByKey(String configKey) async {
    Database database = await DatabaseHelper.instance.database;
    final result = await database.rawQuery(
        '''SELECT * from $tableName where CONFIG_KEY = ? ''', [configKey]);

    if (result.length == 1) {
      return AppConfig.fromMap(result.single);
    } else {
      return Future.value(new AppConfig());
    }
  }
}
