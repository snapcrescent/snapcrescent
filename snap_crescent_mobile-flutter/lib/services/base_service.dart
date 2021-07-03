import 'package:snap_crescent/resository/app_config_resository.dart';
import 'package:snap_crescent/utils/constants.dart';

class BaseService {
  
  Future<String> getServerUrl() async {
    final result =  await AppConfigResository.instance.findByKey(Constants.appConfigServerURL);
    return Future.value(result.configValue);
  }

  String getQueryString(Map params, {String prefix: '&', bool inRecursion: false}) {

    String query = '';

    params.forEach((key, value) {

        if (inRecursion) {
            key = '[$key]';
        }

        if (value is String || value is int || value is double || value is bool) {
            query += '$prefix$key=$value';
        } else if (value is List || value is Map) {
            if (value is List) value = value.asMap();
            value.forEach((k, v) {
                query += getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
            });
        }
   });

   return query;
}

 
}
