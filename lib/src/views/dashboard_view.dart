import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:muserpol_app/src/models/user.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:muserpol_app/src/services/login_service.dart';
import 'package:muserpol_app/src/services/media_app.dart';
import 'package:muserpol_app/src/services/utils.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaApp _media = MediaApp(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Config.appName,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: FutureBuilder(
                future: Utils.user,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    User user = snapshot.data;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DrawerLabel(
                          icon: Icons.local_police_outlined,
                          label: user.degree,
                          media: _media,
                        ),
                        DrawerLabel(
                          icon: Icons.person_outline,
                          label: user.fullName,
                          media: _media,
                        ),
                        DrawerLabel(
                          icon: Icons.contact_page_outlined,
                          label: user.identityCard,
                          media: _media,
                        ),
                      ],
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green[700],
                    Colors.green[800],
                    Colors.green[900],
                    Colors.grey[900],
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[700],
                    offset: Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 80,
                  vertical: 10,
                ),
                child: LogoutButton(context: context),
              ),
            )
          ],
        ),
      ),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Servicios en Línea',
              style: TextStyle(
                fontSize: _media.screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Procedure(
            context: context,
            color: Colors.blue[700],
            icon: Icons.monetization_on,
            label: 'Complemento Económico',
            route: Config.routes['economic_complements'],
            media: _media,
          )
        ],
      ),
    );
  }
}

class Procedure extends StatelessWidget {
  const Procedure({
    Key key,
    @required this.context,
    @required this.color,
    @required this.icon,
    @required this.label,
    @required this.route,
    @required this.media,
  }) : super(key: key);

  final BuildContext context;
  final Color color;
  final IconData icon;
  final String label;
  final String route;
  final MediaApp media;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: media.screenWidth * 0.06,
        vertical: 15,
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pushNamed(route),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: 15,
          ),
          primary: color,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
          ),
          elevation: 7,
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.monetization_on_outlined,
                size: 35,
              ),
              SizedBox(
                width: 15,
              ),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => LoginService.unsetUserData(context),
      style: ElevatedButton.styleFrom(
        primary: Colors.red[700],
        onPrimary: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: 3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        elevation: 7,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Cerrar sesión',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerLabel extends StatelessWidget {
  const DrawerLabel({
    Key key,
    @required this.icon,
    @required this.label,
    @required this.media,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final MediaApp media;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: media.screenWidth * 0.08,
          color: Colors.lightGreen[100],
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: media.screenWidth * 0.0375,
                color: Colors.green[100],
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 1.5,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
