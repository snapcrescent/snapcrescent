import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/local_assets_detail_arguments.dart';
import 'package:snap_crescent/models/local_assets_grid_arguments.dart';
import 'package:snap_crescent/screens/cloud/photos/photo_detail/photo_detail.dart';
import 'package:snap_crescent/screens/cloud/photos/photo_grid/photo_grid.dart';
import 'package:snap_crescent/screens/cloud/videos/video_detail/video_detail.dart';
import 'package:snap_crescent/screens/cloud/videos/video_grid/video_grid.dart';
import 'package:snap_crescent/screens/local/grid/local_asset_detail.dart';
import 'package:snap_crescent/screens/local/grid/local_assets_grid.dart';
import 'package:snap_crescent/screens/local/library/local_library.dart';
import 'package:snap_crescent/screens/local/photo_detail/local_photo_detail.dart';
import 'package:snap_crescent/screens/local/video_detail/local_video_detail.dart';
import 'package:snap_crescent/screens/login/login.dart';
import 'package:snap_crescent/screens/settings/auto_backup_folders/auto_backup_folders.dart';
import 'package:snap_crescent/screens/settings/settings.dart';
import 'package:snap_crescent/screens/splash/splash.dart';
import 'package:snap_crescent/screens/sync_process/sync_process.dart';
import 'package:snap_crescent/stores/local_photo_store.dart';
import 'package:snap_crescent/stores/local_video_store.dart';
import 'package:snap_crescent/stores/photo_store.dart';
import 'package:snap_crescent/stores/video_store.dart';
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
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case SyncProcessScreen.routeName:
        return MaterialPageRoute(builder: (_) => SyncProcessScreen());
      case PhotoGridScreen.routeName:
        return MaterialPageRoute(builder: (_) => PhotoGridScreen());
      case PhotoDetailScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => PhotoDetailScreen(settings.arguments.toString()));
      case SettingsScreen.routeName:
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case AutoBackupFoldersScreen.routeName:
        return MaterialPageRoute(builder: (_) => AutoBackupFoldersScreen());
      case VideoGridScreen.routeName:
        return MaterialPageRoute(builder: (_) => VideoGridScreen());
      case VideoDetailScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => VideoDetailScreen(settings.arguments.toString()));
      case LocalLibraryScreen.routeName:
        return MaterialPageRoute(builder: (_) => LocalLibraryScreen(settings.arguments.toString() as ViewType));
      case LocalAssetsGridScreen.routeName:
        return MaterialPageRoute(builder: (_) => LocalAssetsGridScreen(settings.arguments as LocalAssetsGridArguments));
      case LocalAssetDetailScreen.routeName:
        return MaterialPageRoute(builder: (_) => LocalAssetDetailScreen(settings.arguments as LocalAssetsDetailArguments));
     
      

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
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
