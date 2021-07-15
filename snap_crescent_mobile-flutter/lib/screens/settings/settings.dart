import 'package:flutter/material.dart';
import 'package:snap_crescent/models/sync_info.dart';
import 'package:snap_crescent/screens/login/login.dart';
import 'package:snap_crescent/services/sync_info_service.dart';
import 'package:snap_crescent/style.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: Colors.black,
        ),
        body: _SettingsScreenView());
  }
}

class _SettingsScreenView extends StatefulWidget {
  @override
  _SettingsScreenViewState createState() => _SettingsScreenViewState();
}

class _SettingsScreenViewState extends State<_SettingsScreenView> {
  SyncInfo? lastSyncInfo;

  _clearCache() async {
    await SyncInfoService().deleteAllData();
  }

  _getLastSyncInfo() async {
    final localSyncInfoList = await SyncInfoService().searchOnLocal();

    if (localSyncInfoList.isEmpty == false) {
      this.lastSyncInfo = localSyncInfoList.last;
      return lastSyncInfo!.lastModifiedDatetime.toString();
    } else{
      return "Default";
    }

    
  }

  _settingsList(BuildContext context) {
    return ListView(padding: EdgeInsets.zero, children: <Widget>[
      ListTile(
        title: Text("Clear Cache", style: TitleTextStyle),
        subtitle: Text(_getLastSyncInfo()),
        leading: Container(
          width: 10,
          alignment: Alignment.center,
          child: const Icon(Icons.delete),
        ),
        onTap: () {
          _clearCache();
        },
      ),
      SwitchListTile(
        title: Text("Auto Backup", style: TitleTextStyle),
        secondary: const Icon(Icons.cloud_upload),
        subtitle: Text(
            "Keep your photos and videos by backing them up to your snap-crecent server"),
        isThreeLine: true,
        value: true,
        onChanged: (bool value) {},
      ),
      ListTile(
        title: Text("Logout", style: TitleTextStyle),
        leading: Container(
          width: 10,
          alignment: Alignment.center,
          child: const Icon(Icons.logout),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
              context, LoginScreen.routeName, (r) => false);
        },
      )
    ]);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _settingsList(context);
  }
}
