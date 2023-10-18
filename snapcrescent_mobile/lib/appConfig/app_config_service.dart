import 'package:snapcrescent_mobile/appConfig/app_config.dart';
import 'package:snapcrescent_mobile/appConfig/app_config_repository.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';

class AppConfigService extends BaseService {
  
  static final AppConfigService _singleton = AppConfigService._internal();

  factory AppConfigService() {
    return _singleton;
  }

  AppConfigService._internal();

  updateFlag(String flag, bool value) async {
    AppConfig appConfig =
        AppConfig(configKey: flag, configValue: value.toString());

    await AppConfigRepository().saveOrUpdateConfig(appConfig);
  }

  Future<bool> getFlag(String flag, [bool? defaultValue]) async {
    AppConfig value = await AppConfigRepository().findByKey(flag);

    bool flag0 = false;
    if (value.configValue != null) {
      flag0 = value.configValue == 'true' ? true : false;
    } else if (defaultValue != null) {
      flag0 = defaultValue;
    }

    return flag0;
  }


  Future<DateTime?> getDateConfig(String configKey, String dateFormat) async {
    String? appConfigValueString = await getConfig(configKey);

    DateTime? appConfigValue;

    if (appConfigValueString != null) {
      appConfigValue = DateUtilities().parseDate(appConfigValueString, dateFormat);
    }

    return appConfigValue;
  }

  Future<List<String>> getStringListConfig(String configKey,[Pattern? separator]) async {
    String? appConfigValueString = await getConfig(configKey);

    separator ??= ",";

    if (appConfigValueString != null) {
      return appConfigValueString.split(separator);
    } else {
      return List.empty();
    }
  }

  Future<int?> getIntegerConfig(String configKey) async {
    AppConfig appConfig = await AppConfigRepository().findByKey(configKey);

    int? appConfigValue;

    if (appConfig.configValue != null) {
      appConfigValue = int.parse(appConfig.configValue!);
    } 

    return appConfigValue;
  }
  

  Future<String?> getConfig(String configKey) async {
    AppConfig appConfig = await AppConfigRepository().findByKey(configKey);

    String? appConfigValue;

    if (appConfig.configValue != null) {
      appConfigValue = appConfig.configValue;
    } 

    return appConfigValue;
  }

  Future<void> updateDateConfig(String configKey, DateTime configValue, String dateFormat) async {
    await updateConfig(configKey, DateUtilities().formatDate(configValue,dateFormat));
  }

   updateIntConfig(String configKey, int configValue) async {
    AppConfig appConfig = AppConfig(configKey: configKey, configValue: configValue.toString());

    await AppConfigRepository().saveOrUpdateConfig(appConfig);
  }

  updateConfig(String configKey, String configValue) async {
    AppConfig appConfig = AppConfig(configKey: configKey, configValue: configValue);

    await AppConfigRepository().saveOrUpdateConfig(appConfig);
  }
}
