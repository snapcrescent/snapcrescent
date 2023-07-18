import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snapcrescent_mobile/app.dart';
import 'package:snapcrescent_mobile/screens/settings/settings.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class Header extends StatelessWidget  implements PreferredSizeWidget {
  bool _loggedInToServer = false;

  Future<bool> _getValue() async {
    _loggedInToServer = await AppConfigService.instance
        .getFlag(Constants.appConfigAutoBackupFlag);
    return Future.value(true);
  }

  _body() {
    return new Container(
      color: Colors.black,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Container(
                width: 0,
                height: 0,
              )),
          Expanded(
              flex: 1,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
                Text("Snapcrescent",
                    style: TextStyle(
                      color: Colors.white,
                    ))
              ])),
          Expanded(
              flex: 1,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_getAccountIcon()])),
        ],
      ),
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
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);

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
