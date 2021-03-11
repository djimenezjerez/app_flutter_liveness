import 'package:flutter/material.dart';
import 'package:muserpol_app/src/services/login_service.dart';
import 'package:muserpol_app/src/views/dashboard_view.dart';
import 'package:muserpol_app/src/views/login_view.dart';
import 'package:muserpol_app/src/views/selfie_view.dart';

class RootView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        LoginService.isLoggedIn(context),
        LoginService.isEnrolled(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data[0] && snapshot.data[1]) {
            return DashboardView();
          } else if (snapshot.data[0] && !snapshot.data[1]) {
            return SelfieView(
              enroll: true,
            );
          } else {
            return LoginView();
          }
        } else {
          return LoginView();
        }
      },
    );
  }
}
