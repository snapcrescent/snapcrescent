import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapcrescent_mobile/album/screens/album_list.dart';
import 'package:snapcrescent_mobile/asset/asset_view_arguments.dart';
import 'package:snapcrescent_mobile/asset/screens/asset_list.dart';
import 'package:snapcrescent_mobile/asset/screens/asset_view.dart';
import 'package:snapcrescent_mobile/asset/stores/asset_store.dart';
import 'package:snapcrescent_mobile/settings/screens/settings_list.dart';
import 'package:snapcrescent_mobile/settings/widgets/folder_selection.dart';
import 'package:snapcrescent_mobile/splash/splash.dart';
import 'package:snapcrescent_mobile/style.dart';
import 'package:snapcrescent_mobile/sync/state/sync_state.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SyncState()),
        Provider<AssetStore>(create: (_) => AssetStore()),
      ],
      child: MaterialApp(
        title: 'Snap Crescent',
        debugShowCheckedModeBanner: false,
        initialRoute: SplashScreen.routeName,
        theme: _theme(),
        onGenerateRoute: _generateRoute,
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (BuildContext context) =>
                Scaffold(body: Center(child: Text('Not Found'))),
          );
        },
        navigatorKey: navigatorKey,
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case SettingsListScreen.routeName:
        return MaterialPageRoute(builder: (_) => SettingsListScreen());
      case FolderSelectionScreen.routeName:
        return MaterialPageRoute(
            builder: (_) =>
                FolderSelectionScreen(settings.arguments as String));
      case AlbumListScreen.routeName:
        return MaterialPageRoute(builder: (_) => AlbumListScreen());
      case AssetListScreen.routeName:
        return MaterialPageRoute(builder: (_) => AssetListScreen());
      case AssetViewScreen.routeName:
        return MaterialPageRoute(
            builder: (_) =>
                AssetViewScreen(settings.arguments as AssetViewArguments));
    }
    return null;
  }

  ThemeData _theme() {
    return ThemeData(
      appBarTheme: AppBarTheme(toolbarTextStyle: appBarTextStyle),
      textTheme:
          TextTheme(titleLarge: titleTextStyle, bodyMedium: body1TextStyle),
      primarySwatch: Colors.teal,
    );
  }
}
