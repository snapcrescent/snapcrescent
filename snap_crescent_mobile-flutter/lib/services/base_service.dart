import 'package:dio/dio.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/utils/constants.dart';

class BaseService {

  Dio? _dio;

  Future<Dio> getDio() async {
    if (_dio == null) {
          final baseURL =  await AppConfigRepository.instance.findByKey(Constants.appConfigServerURL);

          BaseOptions options = new BaseOptions(
              baseUrl: baseURL.configValue!,
              receiveDataWhenStatusError: true,
              connectTimeout: 5*1000, // 5 seconds
              receiveTimeout: 300*1000 // 300 seconds
              );

          _dio = new Dio(options);
        }
    return Future.value(_dio);
  }
  
  Future<String> getServerUrl() async {
    final result =  await AppConfigRepository.instance.findByKey(Constants.appConfigServerURL);
    return Future.value(result.configValue);
  }

  Future<bool> isUserLoggedIn() async {
    final result = await AppConfigRepository.instance.findByKey(Constants.appConfigLoggedInFlag);
    return Future.value(result.configValue == "true" ? true : false);
  }

  Future<Options> getHeaders() async {
    
    return Options(
        headers: await getHeadersMap(),
      );
  }

  Future<Map<String, String>> getHeadersMap() async{

    Map<String, String> headers = {};

    final appConfigSessionTokenConfig = await AppConfigRepository.instance.findByKey(Constants.appConfigSessionToken);
    headers["Authorization"] = "Bearer " + appConfigSessionTokenConfig.configValue!;
    

    return headers;
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
