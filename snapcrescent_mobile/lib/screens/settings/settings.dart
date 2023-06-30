import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:snapcrescent_mobile/models/user_login_response.dart';
import 'package:snapcrescent_mobile/screens/grid/assets_grid.dart';
import 'package:snapcrescent_mobile/screens/settings/folder_selection/folder_selection.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/services/asset_service.dart';
import 'package:snapcrescent_mobile/services/notification_service.dart';
import 'package:snapcrescent_mobile/services/settings_service.dart';
import 'package:snapcrescent_mobile/services/toast_service.dart';
import 'package:snapcrescent_mobile/stores/asset/asset_store.dart';
import 'package:snapcrescent_mobile/style.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {

        Navigator.popAndPushNamed(
          context,
          AssetsGridScreen.routeName,
           //if you want to disable back feature set to false
        );

        //we need to return a future
        return Future.value(false);
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Settings'),
            backgroundColor: Colors.black,
          ),
          body: _SettingsScreenView()),
    );
  }
}

class _SettingsScreenView extends StatefulWidget {
  @override
  _SettingsScreenViewState createState() => _SettingsScreenViewState();
}

class _SettingsScreenViewState extends State<_SettingsScreenView> {
  bool _connectedToServer = false;
  String _loggedInUserName = "";
  String _loggedServerName = "";
  bool _autoBackup = false;
  bool _cacheLocally = false;
  bool _showDeviceAssets = false;
  String _latestAssetDate = "Never";
  int _syncedAssetCount = 0;
  String _autoBackupFolders = "None";
  String _showDeviceAssetsFolders = "None";
  String _autoBackupFrequency = "";
  String _autoBackupFrequencyString = "";
  String _appVersion = "";
  AutoBackupFrequencyType _autoBackupFrequencyType = AutoBackupFrequencyType.HOURS;
  
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.onUserInteraction;

  final RegExp _urlRegex = RegExp(
      r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?",
      caseSensitive: false);

  TextEditingController serverURLController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  TextEditingController autoBackUpFrequencyController = TextEditingController();

  late AssetStore _assetStore;

  @override
  Widget build(BuildContext context) {

    _assetStore = Provider.of<AssetStore>(context);

    return FutureBuilder<bool>(
        future: _getSettingsData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: Container(
                width: 60,
                height: 60,
                child: const CircularProgressIndicator(),
              ),
            );
          } else {
            return _settingsList(context);
          }
        });
  }

  FutureOr onBackFromChild(dynamic value) {
    _getSettingsData();
    setState(() {});
  }

  Future<bool> _getSettingsData() async {
    await _getAccountInfo();
    await _getAutoBackupFrequency();
    _connectedToServer =
        await AppConfigService.instance.getFlag(Constants.appConfigLoggedInFlag);
    _autoBackup = await AppConfigService.instance
        .getFlag(Constants.appConfigAutoBackupFlag);
    _autoBackupFolders =
        await SettingsService.instance.getAutoBackupFolderInfo();
    _cacheLocally = await AppConfigService.instance
        .getFlag(Constants.appConfigCacheLocallyFlag);
    _showDeviceAssets = await AppConfigService.instance
        .getFlag(Constants.appConfigShowDeviceAssetsFlag);
    _showDeviceAssetsFolders =
        await SettingsService.instance.getShowDeviceAssetsFolderInfo();
    _latestAssetDate = DateUtilities().formatDate(
        (await AssetService.instance.getLatestAssetDate()),
        DateUtilities.timeStampFormat);

    _syncedAssetCount = await AssetService.instance.countOnLocal();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    _appVersion =
        '''Version : ${packageInfo.version}+${packageInfo.buildNumber}''';

    return Future.value(true);
  }

  Future<void> _getAutoBackupFrequency() async {
    _autoBackupFrequency =
        await SettingsService.instance.getAutoBackupFrequencyInfo();
    _autoBackupFrequencyType = SettingsService.instance
        .getReadableOfAutoBackupFrequency(_autoBackupFrequency);

    double _autoBackupFrequencyNumber = double.parse(_autoBackupFrequency);

    switch (_autoBackupFrequencyType) {
      case AutoBackupFrequencyType.HOURS:
        _autoBackupFrequencyNumber = (_autoBackupFrequencyNumber / 60);
        _autoBackupFrequencyString =
            _autoBackupFrequencyNumber.toStringAsFixed(0) +
                " Hour" +
                (_autoBackupFrequencyNumber > 1 ? "s" : "");
        break;
      case AutoBackupFrequencyType.DAYS:
        _autoBackupFrequencyNumber = ((_autoBackupFrequencyNumber / 60) / 24);
        _autoBackupFrequencyString =
            _autoBackupFrequencyNumber.toStringAsFixed(0) +
                " Day" +
                (_autoBackupFrequencyNumber > 1 ? "s" : "");
        break;
      default:
    }

    this.autoBackUpFrequencyController.text =
        _autoBackupFrequencyNumber.toStringAsFixed(0);
  }

  Future<void> _getAccountInfo() async {
    List<String> result =
        await SettingsService.instance.getAccountInformation();

    this.serverURLController.text = result[0];
    _loggedServerName = this
        .serverURLController
        .text
        .replaceAll("https://", "")
        .replaceAll("http://", "");

    if(_loggedServerName.lastIndexOf(":") > -1) {
      _loggedServerName = _loggedServerName.substring(0, _loggedServerName.lastIndexOf(":"));
    }    
    

    this.nameController.text = result[1];
    _loggedInUserName = this.nameController.text;

    this.passwordController.text = result[2];
  }

  _showAccountInfoDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account'),
          content: Container(
              height: 300,
              child: Form(
                  key: _formKey,
                  child: Column(children: <Widget>[
                    Container(
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
                          decoration: InputDecoration(labelText: 'Server URL')),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                        ),
                      ),
                    )
                  ]))),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            if (_connectedToServer)
              TextButton(
                child: const Text('Logout'),
                onPressed: () {
                  _onLogoutPressed();
                },
              )
            else
              TextButton(
                child: const Text('Login'),
                onPressed: () {
                  _onLoginPressed();
                },
              )
          ],
        );
      },
    );
  }

  _showAutoBackupFrequencyInfoDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Auto Backup Frequency'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                  height: 280,
                  child: Form(
                      key: _formKey,
                      child: Column(children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                              autovalidateMode: _autovalidateMode,
                              controller: autoBackUpFrequencyController,
                              validator: (v) {
                                if (v!.length > 0) {
                                  return null;
                                } else {
                                  return 'Please enter a valid value';
                                }
                              },
                              decoration: InputDecoration(labelText: ''),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ]),
                        ),
                        Container(
                            child: Column(
                          children: <Widget>[
                            ListTile(
                              title: const Text('Hours'),
                              leading: Radio<AutoBackupFrequencyType>(
                                value: AutoBackupFrequencyType.HOURS,
                                groupValue: _autoBackupFrequencyType,
                                onChanged: (AutoBackupFrequencyType? value) {
                                  setState(() {
                                    _autoBackupFrequencyType = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text('Days'),
                              leading: Radio<AutoBackupFrequencyType>(
                                value: AutoBackupFrequencyType.DAYS,
                                groupValue: _autoBackupFrequencyType,
                                onChanged: (AutoBackupFrequencyType? value) {
                                  setState(() {
                                    _autoBackupFrequencyType = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ))
                      ])));
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                _saveAutoBackupFrequency();
                 Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  _saveAutoBackupFrequency() async {
    int selectedValue = int.parse(autoBackUpFrequencyController.text);
    int minutes = 0;
    switch (_autoBackupFrequencyType) {
      case AutoBackupFrequencyType.HOURS:
        minutes = selectedValue * 60;
        break;
      case AutoBackupFrequencyType.DAYS:
        minutes = selectedValue * 60 * 24;
        break;
      default:
    }
    _autoBackupFrequency = minutes.toStringAsFixed(0);

    await AppConfigService.instance.updateConfig(Constants.appConfigAutoBackupFrequency, _autoBackupFrequency);
    await _getAutoBackupFrequency();
    setState(() {});
  }

  _showCacheClearConfirmationDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text('This action cannot be undone')],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                _clearCache();
              },
            )
          ],
        );
      },
    );
  }

  _clearCache() async {
    await AssetService.instance.deleteAllData();
    await _assetStore.refreshStore();
    _latestAssetDate = DateUtilities().formatDate(
        (await AssetService.instance.getLatestAssetDate()),
        DateUtilities.timeStampFormat);
    await AppConfigService.instance.updateDateConfig(Constants.appConfigLastSyncActivityTimestamp, DateTime(2000, 1, 1, 0, 0, 0, 0, 0), DateUtilities.timeStampFormat);
    ToastService.showSuccess("Successfully deleted locally cached data.");
    setState(() {});
    Navigator.pop(context);
  }

  _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      UserLoginResponse userLoginResponse = await SettingsService.instance
          .saveAccountInformation(serverURLController.text, nameController.text,
              passwordController.text);

      if (userLoginResponse.token != null) {
        await AppConfigService.instance
            .updateFlag(Constants.appConfigLoggedInFlag, true);
        await _getAccountInfo();
        await NotificationService.instance.initialize();
        setState(() {});
        Navigator.pop(context);
      } else {
        ToastService.showError("Incorrect Username or Password");
        setState(() {
          _autovalidateMode = AutovalidateMode.always;
        });
      }
    } else {
      ToastService.showError("Please fix the errors");
      setState(() {
        _autovalidateMode = AutovalidateMode.always;
      });
    }
  }

  _onLogoutPressed() async {
    await AppConfigService.instance.updateFlag(Constants.appConfigLoggedInFlag, false);
    await _getAccountInfo();
    setState(() {});
    Navigator.pop(context);
  }

  _updateAutoBackupFlag(bool value) async {
    _autoBackup = value;
    await AppConfigService.instance
        .updateFlag(Constants.appConfigAutoBackupFlag, value);
    setState(() {});
    if (_autoBackup) {
      _autoBackupFolders =
          await SettingsService.instance.getAutoBackupFolderInfo();

      if (_autoBackupFolders.isEmpty) {
        
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FolderSelectionScreen(
                    Constants.appConfigAutoBackupFolders))).then(onBackFromChild);
      }
    }
  }

  _updateCacheLocallyFlag(bool value) async {
    _cacheLocally = value;
    await AppConfigService.instance
        .updateFlag(Constants.appConfigCacheLocallyFlag, value);
    setState(() {});
  }

  _updateShowDeviceAssetsFlag(bool value) async {
    _showDeviceAssets = value;
    await AppConfigService.instance
        .updateFlag(Constants.appConfigShowDeviceAssetsFlag, value);
    setState(() {});

    if (_showDeviceAssets) {
      _showDeviceAssetsFolders =
          await SettingsService.instance.getShowDeviceAssetsFolderInfo();

      if (_showDeviceAssetsFolders.isEmpty) {
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FolderSelectionScreen(
                        Constants.appConfigShowDeviceAssetsFolders)))
            .then(onBackFromChild);
      }
    }
  }

  _settingsList(BuildContext context) {
    return ListView(padding: EdgeInsets.zero, children: <Widget>[
      ListTile(
        title: Text("Account", style: TitleTextStyle),
        subtitle: Text(_connectedToServer == true
            ? '''$_loggedInUserName@$_loggedServerName'''
            : "Not Connected"),
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: const Icon(Icons.account_circle, color: Colors.teal),
        ),
        onTap: () {
          _showAccountInfoDialog();
        },
      ),
      if (_connectedToServer)
        ListTile(
          title: Text("Auto Backup", style: TitleTextStyle),
          subtitle: Text(
              "Automatically backup your photos and videos to your snap-crescent server"),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.cloud_upload, color: Colors.teal),
          ),
          trailing: Switch(
              value: _autoBackup,
              onChanged: (bool value) {
                _updateAutoBackupFlag(value);
              }),
        ),
      if (_autoBackup)
        ListTile(
          title: Text("Auto Backup Frequency ", style: TitleTextStyle),
          subtitle: Text(_autoBackupFrequencyString),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.sync, color: Colors.teal),
          ),
          onTap: () {
            _showAutoBackupFrequencyInfoDialog();
          },
        ),
      if (_autoBackup)
        ListTile(
          title: Text("Backup Folders", style: TitleTextStyle),
          subtitle:
              Text(_autoBackupFolders.isNotEmpty ? _autoBackupFolders : "None"),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.folder, color: Colors.teal),
          ),
          onTap: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FolderSelectionScreen(
                            Constants.appConfigAutoBackupFolders)))
                .then(onBackFromChild);
          },
        ),
      ListTile(
          title: Text("Show Device Photos And Videos", style: TitleTextStyle),
          subtitle:
              Text("Show photos and videos on your device on snap crescent"),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.photo_album, color: Colors.teal),
          ),
          trailing: Switch(
              value: _showDeviceAssets,
              onChanged: (bool value) {
                _updateShowDeviceAssetsFlag(value);
              })),
      if (_showDeviceAssets)
        ListTile(
          title: Text("Device Folders", style: TitleTextStyle),
          subtitle: Text(_showDeviceAssetsFolders.isNotEmpty
              ? _showDeviceAssetsFolders
              : "None"),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.folder, color: Colors.teal),
          ),
          onTap: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FolderSelectionScreen(
                            Constants.appConfigShowDeviceAssetsFolders)))
                .then(onBackFromChild);
          },
        ),
      ListTile(
          title: Text("Cache Photos and Videos Locally", style: TitleTextStyle),
          subtitle: Text(
              "Automatically download photos and videos from your snap-crescent server"),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.cloud_upload, color: Colors.teal),
          ),
          trailing: Switch(
              value: _cacheLocally,
              onChanged: (bool value) {
                _updateCacheLocallyFlag(value);
              }),
        ),
      if (_cacheLocally)
        ListTile(
          title: Text("Local Cache Age ", style: TitleTextStyle),
          subtitle: Text(_autoBackupFrequencyString),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.sync, color: Colors.teal),
          ),
          onTap: () {
            _showAutoBackupFrequencyInfoDialog();
          },
        ),
      ListTile(
        title: Text("Delete Synced Photos and Videos", style: TitleTextStyle),
        subtitle: Text("Last Sync: " +
            (_latestAssetDate.isEmpty ? "Never" : _latestAssetDate) +
            "\n" +
            "Synced Pictures and Videos Count : " +
            _syncedAssetCount.toString()),
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: const Icon(Icons.delete, color: Colors.teal),
        ),
        onTap: () {
          _showCacheClearConfirmationDialog();
        },
      ),
      ListTile(
        title: Text("About App", style: TitleTextStyle),
        subtitle: Text(_appVersion),
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: const Icon(Icons.ac_unit_outlined, color: Colors.teal),
        ),
        onTap: () {},
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
  }
}
