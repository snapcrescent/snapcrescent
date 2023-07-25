import 'package:snapcrescent_mobile/models/app_config.dart';
import 'package:snapcrescent_mobile/repository/app_config_repository.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';

class AppConfigService extends BaseService {
  AppConfigService._privateConstructor() : super();
  static final AppConfigService instance =
      AppConfigService._privateConstructor();

  updateFlag(String flag, bool value) async {
    AppConfig appConfig =
        AppConfig(configKey: flag, configValue: value.toString());

    await AppConfigRepository.instance.saveOrUpdateConfig(appConfig);
  }

  Future<bool> getFlag(String flag, [bool? defaultValue]) async {
    AppConfig value = await AppConfigRepository.instance.findByKey(flag);

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
  

  Future<String?> getConfig(String configKey) async {
    AppConfig appConfig = await AppConfigRepository.instance.findByKey(configKey);

    String? appConfigValue;

    if (appConfig.configValue != null) {
      appConfigValue = appConfig.configValue;
    } 

    return appConfigValue;
  }

  Future<void> updateDateConfig(String configKey, DateTime configValue, String dateFormat) async {
    await updateConfig(configKey, DateUtilities().formatDate(configValue,dateFormat));
  }

  updateConfig(String configKey, String configValue) async {
    AppConfig appConfig =
        AppConfig(configKey: configKey, configValue: configValue);

    await AppConfigRepository.instance.saveOrUpdateConfig(appConfig);
  }
}
