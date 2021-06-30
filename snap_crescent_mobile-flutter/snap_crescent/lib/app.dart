import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/screens/photo_detail/photo_detail.dart';
import 'package:snap_crescent/screens/photos/photos.dart';
import 'package:snap_crescent/screens/photos/photos_store.dart';
import 'package:snap_crescent/style.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        Provider<PhotosStore>(create: (_) => PhotosStore()),
      ],
      child: MaterialApp(
        title: 'Snap Crescent',
        initialRoute: Photos.routeName,
        routes: _routes(),
        theme: _theme(),
      ),
    );
  }

  _routes() {
    return {
      Photos.routeName: (context) => Photos(),
      PhotoDetail.routeName: (context) => PhotoDetail(),
    };
  }

  ThemeData _theme() {
    return ThemeData(
      appBarTheme:
          AppBarTheme(textTheme: TextTheme(headline6: AppBarTextStyle)),
      textTheme:
          TextTheme(headline6: TitleTextStyle, bodyText2: Body1TextStyle),
      primarySwatch: Colors.teal,
    );
  }
}
