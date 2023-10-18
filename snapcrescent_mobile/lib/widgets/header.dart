import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snapcrescent_mobile/appConfig/app_config_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  Header();

  @override
    Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return _HeaderView();
  }
}

class _HeaderView extends StatefulWidget {
  _HeaderView();

   

  @override
  _HeaderViewState createState() => _HeaderViewState();
}

class _HeaderViewState extends State<_HeaderView> {

  bool _loggedInToServer = false;

  Future<bool> _getValue() async {
    _loggedInToServer = await AppConfigService().getFlag(Constants.appConfigAutoBackupFlag);
    return Future.value(true);
  }

  _body() {
    return AppBar(
      backgroundColor: Colors.black,
      centerTitle: true,
      title: Text("Snapcrescent",
                    style: TextStyle(
                      color: Colors.white,
                    )),
      actions: [
        _getAccountIcon()
      ],
    );
  }

  _getAccountIcon() {
    if (_loggedInToServer) {
      return IconButton(
        onPressed: () {
        },
        icon: Icon(Icons.person_outlined),
        color: Colors.white,
      );
    } else {
      return IconButton(
        onPressed: () {
        },
        icon: Icon(Icons.person_off_outlined),
        color: Colors.white,
      );
    }
  }



 

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _getValue(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == null) {
            return Container();
          } else {
            return _body();
          }
        });
  }
}
