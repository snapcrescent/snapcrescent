import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/asset_detail_arguments.dart';
import 'package:snap_crescent/screens/grid/asset_detail.dart';
import 'package:snap_crescent/screens/grid/assets_grid.dart';
import 'package:snap_crescent/screens/settings/folder_seletion/folder_selection.dart';
import 'package:snap_crescent/screens/settings/settings.dart';
import 'package:snap_crescent/screens/splash/splash.dart';
import 'package:snap_crescent/stores/asset/photo_store.dart';
import 'package:snap_crescent/stores/asset/video_store.dart';
import 'package:snap_crescent/stores/widget/sync_process_store.dart';
import 'package:snap_crescent/style.dart';
import 'package:snap_crescent/utils/constants.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PhotoStore>(create: (_) => PhotoStore()),
        Provider<VideoStore>(create: (_) => VideoStore()),
        Provider<SyncProcessStore>(create: (_) => SyncProcessStore()),
      ],
      child: MaterialApp(
        title: 'Snap Crescent',
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
            builder: (_) => AssetsGridScreen(ASSET_TYPE.PHOTO));
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case SettingsScreen.routeName:
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case FolderSelectionScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => FolderSelectionScreen(settings.arguments as AppConfig));
      case AssetsGridScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => AssetsGridScreen(settings.arguments as ASSET_TYPE));
      case AssetDetailScreen.routeName:
        return MaterialPageRoute(
            builder: (_) =>
                AssetDetailScreen(settings.arguments as AssetDetailArguments));

      default:
        return MaterialPageRoute(
            builder: (_) => AssetsGridScreen(ASSET_TYPE.PHOTO));
    }
  }

  ThemeData _theme() {
    return ThemeData(
      appBarTheme:
          AppBarTheme(toolbarTextStyle: AppBarTextStyle),
      textTheme:
          TextTheme(headline6: TitleTextStyle, bodyText2: Body1TextStyle),
      primarySwatch: Colors.teal,
    );
  }
}
