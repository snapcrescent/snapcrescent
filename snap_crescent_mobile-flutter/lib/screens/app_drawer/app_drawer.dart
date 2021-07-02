import 'package:flutter/material.dart';
import 'package:snap_crescent/screens/photo/photo.dart';
import 'package:snap_crescent/screens/settings/settings.dart';
import 'package:snap_crescent/screens/video/video.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(
                  height: 80,
                  child: DrawerHeader(
                    decoration: BoxDecoration(color: Colors.black87),
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
                leading: Icon(Icons.camera),
                title: Text("Photos"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PhotoScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.video_camera_back),
                title: Text("Videos"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => VideoScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingsScreen()));
                },
              )
            ],
          ),
        );
  }
}
