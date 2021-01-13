import 'package:flutter/material.dart';
import 'package:muserpol_app/src/models/user.dart';
import 'package:muserpol_app/src/services/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
        ),
      ),
      body: FutureBuilder(
        future: getUser(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User user = snapshot.data;
            if (user != null) {
              return Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      user.nameWithRank,
                    ),
                    Text(
                      user.ci,
                    ),
                    RaisedButton(
                      onPressed: () {
                        LoginService.unsetUserData(context);
                      },
                      child: Text(
                        'Salir',
                      ),
                      color: Colors.red,
                      textColor: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Future<User> getUser(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> user = prefs.getStringList('user');
      return User(
        id: int.parse(user[0]),
        fullName: user[1],
        rank: user[2],
        ci: user[3],
      );
    } catch (e) {
      LoginService.unsetUserData(context);
      return new User();
    }
  }
}
