import 'package:dio/dio.dart';
import 'package:snap_crescent/resository/app_config_resository.dart';
import 'package:snap_crescent/utils/constants.dart';

class BaseService {

  Dio? _dio;

  Future<Dio> getDio() async {
    if (_dio == null) {
          final baseURL =  await AppConfigResository.instance.findByKey(Constants.appConfigServerURL);

          BaseOptions options = new BaseOptions(
              baseUrl: baseURL.configValue!,
              receiveDataWhenStatusError: true,
              connectTimeout: 5*1000, // 30 seconds
              receiveTimeout: 5*1000 // 30 seconds
              );

          _dio = new Dio(options);
        }
    return Future.value(_dio);
  }
  
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
            if(query.length > 0) {
                query += '$prefix$key=$value';
            } else{
              query += '$key=$value';
            }
            
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
