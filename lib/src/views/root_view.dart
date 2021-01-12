import 'package:flutter/material.dart';
import 'package:muserpol_app/src/services/login_service.dart';
import 'package:muserpol_app/src/views/dashboard_view.dart';
import 'package:muserpol_app/src/views/login_view.dart';

class RootView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LoginService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data) {
            return DashboardView();
          }
        }
        return LoginView();
      },
    );
  }
}
