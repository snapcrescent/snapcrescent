import 'dart:io';

import 'package:dio/dio.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/utils/constants.dart';

class BaseService {

  Dio? _dio;

  Future<Dio> getDio() async {
    final baseURL =  await AppConfigRepository.instance.findByKey(Constants.appConfigServerURL);

    if (_dio == null) {
          
          BaseOptions options = new BaseOptions(
              baseUrl: baseURL.configValue!,
              receiveDataWhenStatusError: true,
              connectTimeout: 60*1000, // 60 seconds
              receiveTimeout: 300*1000 // 300 seconds
              );
  
          _dio = new Dio(options);
        }
    else{
      _dio!.options.baseUrl = baseURL.configValue!;
    }
    return Future.value(_dio);
  }

  
  Future<String> getServerUrl() async {
    final result =  await AppConfigRepository.instance.findByKey(Constants.appConfigServerURL);
    return Future.value(result.configValue!);
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

  Future download(Dio dio, String url,Options options, String savePath) async {

    options.responseType = ResponseType.bytes; 
    options.followRedirects = false; 
    options.validateStatus = (status) {
              return status! < 500;
            }; 

    options.responseType = ResponseType.bytes; 


    try {
      Response response = await dio.get(
        url,
        //Received data with List<int>
        options: options,
      );
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

 
}
