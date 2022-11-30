import 'package:flutter/material.dart';
import 'package:snap_crescent/screens/grid/assets_grid.dart';
import 'package:snap_crescent/screens/settings/settings.dart';

class AppBottomNavigationBar extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return _AppBottomNavigationBarView();
  }
}

class _AppBottomNavigationBarView extends StatefulWidget {
  @override
  _AppBottomNavigationBarState createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<_AppBottomNavigationBarView> {

  @override
  void initState() {
    super.initState();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Navigator.pop(context);
    if(_selectedIndex == 0) {
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => AssetsGridScreen(),
        ),
        (route) => false,//if you want to disable back feature set to false
      );
    } else if(_selectedIndex == 1) {
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => SettingsScreen(),
        ),
        (route) => false,//if you want to disable back feature set to false
      );
     } 
  }


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      iconSize: 30,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      onTap: _onItemTapped,
      items: [
        new BottomNavigationBarItem(
          icon: Icon(Icons.camera),
          label: "Photos & Videos",
        ),
        new BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Settings",
        )
      ],
    );
  }
}
