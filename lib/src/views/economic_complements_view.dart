import 'package:flutter/material.dart';
import 'package:muserpol_app/src/models/user.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:muserpol_app/src/services/utils.dart';
import 'package:muserpol_app/src/services/login_service.dart';
import 'package:muserpol_app/src/views/economic_complement_list_view.dart';
import 'package:muserpol_app/src/views/economic_complements_current_view.dart';

class EconomicComplementsView extends StatefulWidget {
  final String dialogMessage;

  const EconomicComplementsView({
    Key key,
    this.dialogMessage = '',
  }) : super(key: key);

  @override
  _EconomicComplementsViewState createState() =>
      _EconomicComplementsViewState();
}

class _EconomicComplementsViewState extends State<EconomicComplementsView> {
  bool _loading;

  @override
  void initState() {
    _loading = true;
    _verifyEnroll();
    super.initState();
    _showDialog(
      delayed: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Complemento Económico'),
          bottom: TabBar(
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: const EdgeInsets.symmetric(horizontal: 30),
            indicator: BoxDecoration(
              color: Colors.green[600],
              border: Border(
                bottom: BorderSide(
                  color: Colors.blueGrey,
                  width: 3,
                ),
              ),
            ),
            tabs: [
              Tab(
                text: 'Trámites Vigentes',
              ),
              Tab(
                text: 'Trámites Históricos',
              )
            ],
          ),
        ),
        drawer: drawerProfile(),
        body: _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                children: [
                  EconomicComplementsCurrentView(),
                  EconomicComplementListView(
                    current: false,
                  ),
                ],
              ),
      ),
    );
  }

  void _showDialog({delayed = false}) async {
    if (delayed) {
      await Future.delayed(Duration(
        milliseconds: 100,
      ));
    }
    if (widget.dialogMessage != '') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'PROCESO CONCLUÍDO',
              textAlign: TextAlign.center,
            ),
            content: Text(
              widget.dialogMessage,
              textAlign: TextAlign.justify,
            ),
            actions: [
              TextButton(
                child: Text('ACEPTAR'),
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

  Widget drawerProfile() {
    return Drawer(
      child: Column(
        children: [
          Expanded(
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
                                label: Flexible(
                                  child: Text(user.fullName),
                                ),
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                ),
                              ),
                              if (user.degree != null)
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.local_police_outlined),
                                  label: Flexible(
                                    child: Text('GRADO: ' + user.degree),
                                  ),
                                  style: TextButton.styleFrom(
                                    primary: Colors.black,
                                  ),
                                ),
                              TextButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.contact_page_outlined),
                                label: Flexible(
                                  child: Text('C.I.: ' + user.identityCard),
                                ),
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                ),
                              ),
                              if (user.category != null)
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.av_timer),
                                  label: Flexible(
                                    child: Text('CATEGORÍA: ' + user.category),
                                  ),
                                  style: TextButton.styleFrom(
                                    primary: Colors.black,
                                  ),
                                ),
                              TextButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.account_balance),
                                label: Flexible(
                                  child: Text('GESTORA: ' + user.pensionEntity),
                                ),
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
          Padding(
            padding: const EdgeInsets.only(
              left: 5,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text('Versión: ' + Config.apkVersion),
            ),
          ),
        ],
      ),
    );
  }
}
