import 'package:flutter/material.dart';
import 'package:snap_crescent/screens/grid/assets_grid.dart';
import 'package:snap_crescent/screens/local/library/local_library.dart';
import 'package:snap_crescent/screens/settings/settings.dart';
import 'package:snap_crescent/utils/constants.dart';

class AppDrawer extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return _AppDrawerView();
  }
}

class _AppDrawerView extends StatefulWidget {
  @override
  _AppDrawerViewState createState() => _AppDrawerViewState();
}

class _AppDrawerViewState extends State<_AppDrawerView> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
              height: 90,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.black),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Snap Crescent",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w300,
                          color: Colors.white),
                    )
                  ],
                ),
              )),
          ListTile(
            leading: Icon(Icons.cloud),
            title: Text("Cloud"),
            onTap: () {},
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: ListTile(
                leading: Icon(Icons.camera),
                title: Text("Photos"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AssetsGridScreen(ASSET_TYPE.PHOTO)));
                },
              )),
          Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: ListTile(
                leading: Icon(Icons.video_camera_back),
                title: Text("Videos"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AssetsGridScreen(ASSET_TYPE.VIDEO)));
                },
              )),
          ListTile(
            leading: Icon(Icons.folder),
            title: Text("Local"),
            onTap: () {},
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: ListTile(
                leading: Icon(Icons.camera),
                title: Text("Photos"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LocalLibraryScreen(ASSET_TYPE.PHOTO)));
                },
              )),
          Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: ListTile(
                leading: Icon(Icons.video_camera_back),
                title: Text("Videos"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LocalLibraryScreen(ASSET_TYPE.VIDEO)));
                },
              )),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          )
        ],
      ),
    );
  }
}
