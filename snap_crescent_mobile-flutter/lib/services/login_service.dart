import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/user_login_request.dart';
import 'package:snap_crescent/models/user_login_response.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/services/base_service.dart';
import 'package:snap_crescent/utils/constants.dart';

class LoginService extends BaseService {

  LoginService._privateConstructor():super();
  static final LoginService instance = LoginService._privateConstructor();

  Future<UserLoginResponse> login() async {
    try {
      final appConfigServerUserNameConfig = await AppConfigRepository.instance.findByKey(Constants.appConfigServerUserName);
      final appConfigServerPasswordConfig = await AppConfigRepository.instance.findByKey(Constants.appConfigServerPassword);

      if (appConfigServerUserNameConfig.configValue != null && appConfigServerPasswordConfig.configValue != null) {

        UserLoginRequest request = new UserLoginRequest(username : appConfigServerUserNameConfig.configValue , password : appConfigServerPasswordConfig.configValue);

        Dio dio = await getDio();
        print(request.toJson());
        final jsonResponse = await dio.post('/login', data : request.toJson());

        UserLoginResponse response = UserLoginResponse.fromJson(json.decode(jsonResponse.data));

        AppConfig appConfigSessionTokenConfig = new AppConfig(configKey: Constants.appConfigSessionToken,configValue: response.token);
        await AppConfigRepository.instance.saveOrUpdateConfig(appConfigSessionTokenConfig);

        return response;

      } else {
        return new UserLoginResponse();
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      return new UserLoginResponse();
    }
  }
}
