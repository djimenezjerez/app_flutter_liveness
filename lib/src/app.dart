import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:muserpol_app/src/views/selfie_view.dart';
import 'package:muserpol_app/src/views/contacts_view.dart';
import 'package:muserpol_app/src/views/dashboard_view.dart';
import 'package:muserpol_app/src/views/economic_complements_view.dart';
import 'package:muserpol_app/src/views/login_view.dart';
import 'package:muserpol_app/src/views/root_view.dart';

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.lightGreen[100],
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp(
      title: 'MUSERPOL',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green[800],
        accentColor: Colors.green[300],
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Config.routes['root'],
      routes: {
        Config.routes['root']: (context) => RootView(),
        Config.routes['login']: (context) => LoginView(),
        Config.routes['contacts']: (context) => ContactsView(),
        Config.routes['dashboard']: (context) => DashboardView(),
        Config.routes['economic_complements']: (context) =>
            EconomicComplementsView(),
        Config.routes['selfie']: (context) => SelfieView(),
      },
    );
  }
}
