import 'dart:async';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapcrescent_mobile/models/asset/asset_view_arguments.dart';
import 'package:snapcrescent_mobile/models/sync_state.dart';
import 'package:snapcrescent_mobile/screens/asset/asset_view.dart';
import 'package:snapcrescent_mobile/screens/settings/settings.dart';
import 'package:snapcrescent_mobile/services/toast_service.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';
import 'package:snapcrescent_mobile/utils/common_utilities.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/screens/asset/widgets/asset_thumbnail.dart';
import 'package:snapcrescent_mobile/screens/asset/widgets/config_server_prompt.dart';
import 'package:snapcrescent_mobile/screens/asset/widgets/sync_process.dart';
import 'package:snapcrescent_mobile/widgets/footer.dart';
import 'package:snapcrescent_mobile/widgets/header.dart';

class AlbumListScreen extends StatelessWidget {
  static const routeName = '/assets';
  AlbumListScreen();
  @override
  Widget build(BuildContext context) {
    return _AlbumListView();
  }
}

class _AlbumListView extends StatefulWidget {
  _AlbumListView();

  @override
  _AlbumListViewState createState() => _AlbumListViewState();
}

class _AlbumListViewState extends State<_AlbumListView> {
  DateTime currentDateTime = DateTime.now();
  final ScrollController _scrollController = new ScrollController();
  bool showProcessing = false;
  int gridPageNumber = 0;

  Timer? timer;
  int periodicInitializerPageNumber = 0;

  _onAssetTap(BuildContext context, int assetIndex) {
    AssetViewArguments arguments =
        new AssetViewArguments(assetIndex: assetIndex);

    Navigator.pushNamed(
      context,
      AssetViewScreen.routeName,
      arguments: arguments,
    );
  }





  _updateProcessingBarVisibility(bool isVisible) {
    showProcessing = isVisible;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {

        Timer(Duration(seconds: 2), () => setState(() {}));
      }
    });

    
      
      
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }






  _body() {
    return Scaffold(
      appBar: Header(),
      bottomNavigationBar: Footer(),
      body: Container(
        color: Colors.black,
        child: new Stack(fit: StackFit.expand, children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: ConfigServerPromptWidget(),
              )
            ],
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }
}
