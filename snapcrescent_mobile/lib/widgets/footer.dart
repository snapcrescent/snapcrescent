import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snapcrescent_mobile/screens/album/album_list.dart';
import 'package:snapcrescent_mobile/screens/asset/asset_list.dart';
import 'package:snapcrescent_mobile/screens/settings/settings.dart';
import 'package:snapcrescent_mobile/services/global_service.dart';

class Footer extends StatelessWidget {
  Footer();
  @override
  Widget build(BuildContext context) {
    return _FooterView();
  }
}

class _FooterView extends StatefulWidget {
  _FooterView();

  @override
  _FooterViewState createState() => _FooterViewState();
}

class _FooterViewState extends State<_FooterView> {
  int _selectedIndex = 0;

  Future<bool> _getValue() async {
    
    setState(() {
      _selectedIndex = GlobalService.instance.bottomNavigationBarIndex;
    });

    return Future.value(true);
  }

  _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    GlobalService.instance.bottomNavigationBarIndex = index;

    switch (index) {
      case 0:
         Navigator.pushAndRemoveUntil<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => AssetListScreen(),
          ),
          (route) => false, //if you want to disable back feature set to false
        );
        break;
      case 9:
        Navigator.pushAndRemoveUntil<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => AlbumListScreen(),
          ),
          (route) => false, //if you want to disable back feature set to false
        );
        break;
      case 9:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => AssetListScreen()));
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => SettingsScreen()));
        break;
    }
  }

  _body() {
    return new Container(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (int index) => _onTap(index),
          currentIndex: _selectedIndex,
          backgroundColor: Colors.black,
          unselectedItemColor: Colors.white,
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.photo),
              label: "Photos",
            ),
            /*
            new BottomNavigationBarItem(
              icon: Icon(Icons.album),
              label: "Albums",
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: "Library",
            ),
            */
            new BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _getValue(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == null) {
            return new Container();
          } else {
            return _body();
          }
        });
  }
}
