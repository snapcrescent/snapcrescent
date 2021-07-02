import 'package:flutter/material.dart';
import 'package:snap_crescent/screens/app_drawer/app_drawer.dart';

class VideoScreen extends StatelessWidget {
  static const routeName = '/video';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Videos'),
          backgroundColor: Colors.black,
        ),
        drawer: AppDrawer(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[],
        ));
  }
}
