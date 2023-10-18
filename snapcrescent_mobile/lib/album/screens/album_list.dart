import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snapcrescent_mobile/widgets/footer.dart';
import 'package:snapcrescent_mobile/widgets/header.dart';

class AlbumListScreen extends StatelessWidget {
  static const routeName = '/albums';
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
  final ScrollController _scrollController = ScrollController();
  bool showProcessing = false;
  int gridPageNumber = 0;

  Timer? timer;
  int periodicInitializerPageNumber = 0;



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
        child: Stack(fit: StackFit.expand, children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
             
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
