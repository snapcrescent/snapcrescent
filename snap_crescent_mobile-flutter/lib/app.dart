import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/asset_detail_arguments.dart';
import 'package:snap_crescent/models/assets_grid_arguments.dart';
import 'package:snap_crescent/screens/grid/asset_detail.dart';
import 'package:snap_crescent/screens/grid/assets_grid.dart';
import 'package:snap_crescent/screens/local/grid/local_asset_detail.dart';
import 'package:snap_crescent/screens/local/grid/local_assets_grid.dart';
import 'package:snap_crescent/screens/local/library/local_library.dart';
import 'package:snap_crescent/screens/settings/folder_seletion/folder_selection.dart';
import 'package:snap_crescent/screens/settings/settings.dart';
import 'package:snap_crescent/screens/splash/splash.dart';
import 'package:snap_crescent/stores/local/local_photo_store.dart';
import 'package:snap_crescent/stores/local/local_video_store.dart';
import 'package:snap_crescent/stores/asset/photo_store.dart';
import 'package:snap_crescent/stores/asset/video_store.dart';
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
        Provider<LocalPhotoStore>(create: (_) => LocalPhotoStore()),
        Provider<LocalVideoStore>(create: (_) => LocalVideoStore())
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

      case LocalLibraryScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => LocalLibraryScreen(
                settings.arguments.toString() as ASSET_TYPE));
      case LocalAssetsGridScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => LocalAssetsGridScreen(
                settings.arguments as AssetGridArguments));
      case LocalAssetDetailScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => LocalAssetDetailScreen(
                settings.arguments as AssetDetailArguments));

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
