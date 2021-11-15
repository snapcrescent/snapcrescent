import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/resository/app_config_resository.dart';
import 'package:snap_crescent/screens/grid/assets_grid.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/utils/constants.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Snap Crescent'),
          centerTitle: true,
        ),
        body: _LoginScreenView());
  }
}

class _LoginScreenView extends StatefulWidget {
  @override
  _LoginScreenViewState createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<_LoginScreenView> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.onUserInteraction;

  final RegExp _urlRegex = RegExp(
      r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?",
      caseSensitive: false);

  TextEditingController serverURLController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  _setDefaultAppConfig() async {
    AppConfig firstBootConfig = await AppConfigResository.instance
        .findByKey(Constants.appConfigFirstBootFlag);

    // This is first boot of application
    if (firstBootConfig.configValue == null) {
      firstBootConfig.configkey = Constants.appConfigFirstBootFlag;
      firstBootConfig.configValue = "false";

      await AppConfigResository.instance.saveOrUpdateConfig(firstBootConfig);

      AppConfig appConfigShowDeviceAssetsFlagConfig = new AppConfig(
          configkey: Constants.appConfigShowDeviceAssetsFlag,
          configValue: "true");

      await AppConfigResository.instance
          .saveOrUpdateConfig(appConfigShowDeviceAssetsFlagConfig);

      if (!await PhotoManager.requestPermission()) {
        ToastService.showError('Permission to device folders denied!');
        return Future.value([]);
      }

      final List<AssetPathEntity> folders =
          await PhotoManager.getAssetPathList();
      folders.sort(
          (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

      List<AssetPathEntity> cameraFolders = folders
          .where((folder) =>
              folder.name.toLowerCase() == "camera" ||
              folder.name.toLowerCase() == "pictures" ||
              folder.name.toLowerCase() == "portrait" ||
              folder.name.toLowerCase() == "selfies" ||
              folder.name.toLowerCase() == "portrait" ||
              folder.name.toLowerCase() == "raw" ||
              folder.name.toLowerCase() == "videos")
          .toList();

      AppConfig appConfigShowDeviceAssetsFoldersFlagConfig = new AppConfig(
          configkey: Constants.appConfigShowDeviceAssetsFolders,
          configValue: cameraFolders
              .map((assetPathEntity) => assetPathEntity.id)
              .join(","));

      await AppConfigResository.instance
          .saveOrUpdateConfig(appConfigShowDeviceAssetsFoldersFlagConfig);
    }
  }

  _onLoginPressed() async {
    AppConfig serverUrlConfig = new AppConfig(
        configkey: Constants.appConfigServerURL,
        configValue: serverURLController.text);

    AppConfig serverUserNameConfig = new AppConfig(
        configkey: Constants.appConfigServerUserName,
        configValue: nameController.text);

    AppConfig serverPasswordConfig = new AppConfig(
        configkey: Constants.appConfigServerPassword,
        configValue: passwordController.text);

    await AppConfigResository.instance.saveOrUpdateConfig(serverUrlConfig);
    await AppConfigResository.instance.saveOrUpdateConfig(serverUserNameConfig);
    await AppConfigResository.instance.saveOrUpdateConfig(serverPasswordConfig);

    await this._setDefaultAppConfig();

    Navigator.pushReplacementNamed(context,  AssetsGridScreen.routeName,arguments: ASSET_TYPE.PHOTO);
  }

  _showValidationErrors() {
    ToastService.showError("Please fix the errors");
  }

  @override
  void initState() {
    super.initState();

    AppConfigResository.instance
        .findByKey(Constants.appConfigServerURL)
        .then((value) => {
              if (value.configValue != null)
                {this.serverURLController.text = value.configValue!}
              else
                {this.serverURLController.text = "http://192.168.0.16:8080"}
            });

    AppConfigResository.instance
        .findByKey(Constants.appConfigServerUserName)
        .then((value) => {
              if (value.configValue != null)
                {this.nameController.text = value.configValue!}
              else
                {this.nameController.text = "Username"}
            });

    AppConfigResository.instance
        .findByKey(Constants.appConfigServerPassword)
        .then((value) => {
              if (value.configValue != null)
                {this.passwordController.text = value.configValue!}
              else
                {this.passwordController.text = "Password"}
            });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: ListView(children: <Widget>[
                      Expanded(
                          child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Sign in',
                                style: TextStyle(fontSize: 20),
                              ))),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          autovalidateMode: _autovalidateMode,
                          controller: serverURLController,
                          validator: (v) {
                            if (v!.length > 0 && _urlRegex.hasMatch(v)) {
                              return null;
                            } else {
                              return 'Please enter a valid url';
                            }
                          },
                          decoration: InputDecoration(labelText: 'Server URL'),
                        ),
                      )),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'User Name',
                          ),
                        ),
                      )),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: TextField(
                          obscureText: true,
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                          ),
                        ),
                      )),
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: ElevatedButton(
                            child: Text("Login"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _onLoginPressed();
                              } else {
                                _showValidationErrors();
                                setState(() {
                                  _autovalidateMode = AutovalidateMode.always;
                                });
                              }
                            },
                          ))
                    ])))
          ],
        ));
  }
}
