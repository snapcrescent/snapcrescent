import 'package:flutter/material.dart';
import 'package:snap_crescent/screens/app_drawer/app_drawer.dart';
import 'package:snap_crescent/screens/login/login.dart';
import 'package:snap_crescent/services/sync_info_service.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  _clearCache() async {
   await SyncInfoService().deleteAllData();
  }

  _setttingsList(BuildContext context) {
    return ListView(padding: EdgeInsets.zero, children: <Widget>[
      ListTile(
        title: Text("Clear Cache"),
        onTap: () {
          _clearCache();
        },
      ),
      ListTile(
        title: Text("Logout"),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
              context, LoginScreen.routeName, (r) => false);
        },
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: Colors.black,
        ),
        drawer: AppDrawer(),
        body: _setttingsList(context));
  }
}
