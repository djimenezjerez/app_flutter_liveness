import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muserpol_app/src/views/contacts_view.dart';
import 'package:muserpol_app/src/views/login_view.dart';

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      title: 'MUSERPOL',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green[800],
        accentColor: Colors.green[300],
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginView(),
        '/contacts': (context) => ContactsView(),
      },
    );
  }
}
