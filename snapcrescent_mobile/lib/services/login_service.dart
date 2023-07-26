import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:snapcrescent_mobile/models/user/account_info.dart';
import 'package:snapcrescent_mobile/models/user/user_login_request.dart';
import 'package:snapcrescent_mobile/models/user/user_login_response.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class LoginService extends BaseService {
  static final LoginService _singleton = LoginService._internal();

  factory LoginService() {
    return _singleton;
  }

  LoginService._internal();

  Future<UserLoginResponse?> login(
      String serverUrl, String username, String password) async {
    UserLoginResponse? response;

    try {
      saveAccountInformation(serverUrl, username, password);

      UserLoginRequest request =
          UserLoginRequest(username: username, password: password);

      Dio dio = await getDio();
      final jsonResponse = await dio.post('/login', data: request.toJson());

      response = UserLoginResponse.fromJson(json.decode(jsonResponse.data));

      await AppConfigService()
          .updateConfig(Constants.appConfigSessionToken, response.token!);
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection  Timeout Exception");
      } else if (ex.type == DioExceptionType.unknown) {
        throw Exception("Unable to connect to server");
      }
    }

    return response;
  }

  Future<AccountInfo> getAccountInformation() async {
    String? serverUrl =
        await AppConfigService().getConfig(Constants.appConfigServerURL);
    serverUrl ??= "https://";
    String? username =
        await AppConfigService().getConfig(Constants.appConfigServerUserName);
    username ??= "";
    String? password =
        await AppConfigService().getConfig(Constants.appConfigServerPassword);
    password ??= "";

    return AccountInfo(serverUrl, username, password);
  }

  Future<void> saveAccountInformation(
      String serverUrl, String username, String password) async {
    await AppConfigService()
        .updateConfig(Constants.appConfigServerURL, serverUrl);
    await AppConfigService()
        .updateConfig(Constants.appConfigServerUserName, username);
    await AppConfigService()
        .updateConfig(Constants.appConfigServerPassword, password);
  }
}
