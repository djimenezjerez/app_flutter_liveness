import 'package:flutter/material.dart';
import 'package:muserpol_app/src/models/user.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:muserpol_app/src/services/login_service.dart';
import 'package:muserpol_app/src/services/utils.dart';

class DashboardView extends StatefulWidget {
  final String dialogMessage;

  const DashboardView({
    Key key,
    this.dialogMessage = '',
  }) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _loading;

  @override
  void initState() {
    _loading = true;
    _verifyEnroll();
    super.initState();
    _showDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complemento Económico'),
      ),
      drawer: Drawer(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green[800],
                    Colors.grey[900],
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
              width: double.infinity,
              child: DrawerHeader(
                child: Image(
                  image: AssetImage(
                    'assets/images/muserpol-logo.png',
                  ),
                  repeat: ImageRepeat.noRepeat,
                  alignment: Alignment.center,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 10,
              ),
              child: FutureBuilder(
                future: Utils.user,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    User user = snapshot.data;
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.person_outline),
                            label: Text(user.fullName),
                            style: TextButton.styleFrom(
                              primary: Colors.black,
                            ),
                          ),
                          if (user.degree != null)
                            TextButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.local_police_outlined),
                              label: Text(user.degree),
                              style: TextButton.styleFrom(
                                primary: Colors.black,
                              ),
                            ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.contact_page_outlined),
                            label: Text('C.I.: ' + user.identityCard),
                            style: TextButton.styleFrom(
                              primary: Colors.black,
                            ),
                          ),
                          if (user.category != null)
                            TextButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.av_timer),
                              label: Text('CATEGORÍA: ' + user.category),
                              style: TextButton.styleFrom(
                                primary: Colors.black,
                              ),
                            ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.account_balance),
                            label: Text('GESTORA: ' + user.pensionEntity),
                            style: TextButton.styleFrom(
                              primary: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                onPressed: () {
                  _loading = true;
                  LoginService.unsetUserData(context);
                },
                icon: Icon(
                  Icons.error_outline,
                ),
                label: Text('Cerrar sesión'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 40,
        ),
        child: _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return Colors.blueGrey;
                        },
                      ),
                      padding: MaterialStateProperty.resolveWith<EdgeInsets>(
                        (Set<MaterialState> states) {
                          return EdgeInsets.symmetric(vertical: 25);
                        },
                      ),
                      elevation: MaterialStateProperty.resolveWith<double>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return 0;
                          }
                          return 10;
                        },
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    ),
                    child: Text(
                      'Complemento Económico',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pushNamed(
                      Config.routes['economic_complements'],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showDialog() async {
    if (widget.dialogMessage != '') {
      await Future.delayed(Duration(
        milliseconds: 100,
      ));
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Proceso completado'),
            content: Text(widget.dialogMessage),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _verifyEnroll() async {
    try {
      bool enrolled = await LoginService.isEnrolled();
      if (!enrolled) {
        await Future.delayed(Duration(
          milliseconds: 100,
        ));
        LoginService.unsetUserData(context);
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
