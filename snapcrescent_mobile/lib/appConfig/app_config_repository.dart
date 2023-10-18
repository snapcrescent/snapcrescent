import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapcrescent_mobile/appConfig/app_config.dart';
import 'package:snapcrescent_mobile/common/repository/base_repository.dart';

class AppConfigRepository extends BaseRepository {
  static const _tableName = 'APP_CONFIG';

  static final AppConfigRepository _singleton = AppConfigRepository._internal();

  factory AppConfigRepository() {
    return _singleton;
  }

  AppConfigRepository._internal() : super(_tableName);

  Future<void> saveOrUpdateConfig(AppConfig entity) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(entity.configKey!, entity.configValue!);
  }

  Future<AppConfig> findByKey(String configKey) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? configValue = sharedPreferences.getString(configKey);

    if (configValue != null) {
      return AppConfig(
        configKey : configKey,
        configValue : configValue
      );
    } else {
      return Future.value(AppConfig());
    }
  }
}
