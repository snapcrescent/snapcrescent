import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapcrescent_mobile/models/app_config.dart';
import 'package:snapcrescent_mobile/models/asset_detail_arguments.dart';
import 'package:snapcrescent_mobile/screens/grid/asset_detail.dart';
import 'package:snapcrescent_mobile/screens/grid/assets_grid.dart';
import 'package:snapcrescent_mobile/screens/settings/folder_selection/folder_selection.dart';
import 'package:snapcrescent_mobile/screens/settings/settings.dart';
import 'package:snapcrescent_mobile/screens/splash/splash.dart';
import 'package:snapcrescent_mobile/stores/asset/asset_store.dart';
import 'package:snapcrescent_mobile/style.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AssetStore>(create: (_) => AssetStore()),
      ],
      child: MaterialApp(
        title: 'Snap Crescent',
        debugShowCheckedModeBanner: false,
        initialRoute: SplashScreen.routeName,
        theme: _theme(),
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
            builder: (_) => AssetsGridScreen());
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case SettingsScreen.routeName:
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case FolderSelectionScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => FolderSelectionScreen(settings.arguments as AppConfig));
      case AssetsGridScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => AssetsGridScreen());
      case AssetDetailScreen.routeName:
        return MaterialPageRoute(
            builder: (_) =>
                AssetDetailScreen(settings.arguments as AssetDetailArguments));

      default:
        return MaterialPageRoute(
            builder: (_) => AssetsGridScreen());
    }
  }

  ThemeData _theme() {
    return ThemeData(
      appBarTheme:
          AppBarTheme(toolbarTextStyle: AppBarTextStyle),
      textTheme:
          TextTheme(titleLarge: TitleTextStyle, bodyMedium: Body1TextStyle),
      primarySwatch: Colors.teal,
    );
  }
}
