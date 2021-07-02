import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snap_crescent/screens/app_drawer/app_drawer.dart';

class HomeScreen extends StatefulWidget {

  static const routeName = '/home';
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Navigation Drawer"),
      ),
      drawer: AppDrawer(), // this is drawerCode page
    );
  }
}
