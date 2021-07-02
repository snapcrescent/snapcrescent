import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/screens/home/home_screen.dart';
import 'package:snap_crescent/screens/login/login.dart';
import 'package:snap_crescent/screens/photo_detail/photo_detail.dart';
import 'package:snap_crescent/screens/photo/photo.dart';
import 'package:snap_crescent/screens/photo/photo_store.dart';
import 'package:snap_crescent/screens/settings/settings.dart';
import 'package:snap_crescent/screens/splash/splash.dart';
import 'package:snap_crescent/screens/video/video.dart';
import 'package:snap_crescent/style.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PhotoStore>(create: (_) => PhotoStore()),
      ],
      child: MaterialApp(
        title: 'Snap Crescent',
        initialRoute: SplashScreen.routeName,
        // routes: _routes(),
        theme: _theme(),
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case HomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case PhotoScreen.routeName:
        return MaterialPageRoute(builder: (_) => PhotoScreen());
      case PhotoDetail.routeName:
        return MaterialPageRoute(builder: (_) => PhotoDetail(settings.arguments.toString()));
      case SettingsScreen.routeName:
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case VideoScreen.routeName:
        return MaterialPageRoute(builder: (_) => VideoScreen());

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }

  /*
  _routes() {
    return {
      SplashScreen.routeName: (context) => SplashScreen(),
      LoginScreen.routeName: (context) => LoginScreen(),
      HomeScreen.routeName: (context) => HomeScreen(),
      PhotoScreen.routeName: (context) => PhotoScreen(),
      PhotoDetail.routeName: (context) => PhotoDetail(),
      SettingsScreen.routeName: (context) => SettingsScreen(),
      VideoScreen.routeName: (context) => VideoScreen(),
    };
    
  }
  */

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
