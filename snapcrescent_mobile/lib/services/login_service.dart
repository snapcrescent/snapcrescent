import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:snapcrescent_mobile/models/app_config.dart';
import 'package:snapcrescent_mobile/models/user/user_login_request.dart';
import 'package:snapcrescent_mobile/models/user/user_login_response.dart';
import 'package:snapcrescent_mobile/repository/app_config_repository.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class LoginService extends BaseService {

  LoginService._privateConstructor():super();
  static final LoginService instance = LoginService._privateConstructor();

  Future<UserLoginResponse?> login() async {
    
    UserLoginResponse? response;

    try {
      final appConfigServerUserNameConfig = await AppConfigRepository.instance.findByKey(Constants.appConfigServerUserName);
      final appConfigServerPasswordConfig = await AppConfigRepository.instance.findByKey(Constants.appConfigServerPassword);

      if (appConfigServerUserNameConfig.configValue != null && appConfigServerPasswordConfig.configValue != null) {

        UserLoginRequest request = UserLoginRequest(username : appConfigServerUserNameConfig.configValue , password : appConfigServerPasswordConfig.configValue);

        Dio dio = await getDio();
        final jsonResponse = await dio.post('/login', data : request.toJson());

        response = UserLoginResponse.fromJson(json.decode(jsonResponse.data));

        AppConfig appConfigSessionTokenConfig = AppConfig(configKey: Constants.appConfigSessionToken,configValue: response.token);
        await AppConfigRepository.instance.saveOrUpdateConfig(appConfigSessionTokenConfig);

      } 
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection  Timeout Exception");
      } else if (ex.type == DioExceptionType.unknown) {
        throw Exception("Unable to connect to server");
      }
    }

    return response;
  }
}
