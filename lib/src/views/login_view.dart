import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muserpol_app/src/services/media_app.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _loading = false;
  final _loginForm = GlobalKey<FormState>();
  final _ci = TextEditingController();
  final _complement = TextEditingController();
  String _error = '';

  @override
  Widget build(BuildContext context) {
    MediaApp _media = MediaApp(context);

    return Scaffold(
      body: Stack(
        children: [
          logoImage(),
          Center(
            child: SingleChildScrollView(
              child: Transform.translate(
                offset: Offset(
                  0,
                  -0.20 * _media.screenHeight,
                ),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  margin: EdgeInsets.only(
                    left: _media.screenWidth * (_media.isPortrait ? 0.1 : 0.38),
                    right:
                        _media.screenWidth * (_media.isPortrait ? 0.1 : 0.38),
                    top: _media.screenHeight * (_media.isPortrait ? 0.5 : 0.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 20,
                    ),
                    child: Form(
                      key: _loginForm,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Sistema de Trámites en Línea',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: _media.screenHeight * 0.027,
                                color: Colors.green[800],
                                shadows: [
                                  Shadow(
                                    color: Colors.grey,
                                    offset: Offset(1, 1),
                                    blurRadius: 1.5,
                                  )
                                ]),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          if (_error.isNotEmpty)
                            Text(
                              _error,
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (_error.isNotEmpty)
                            SizedBox(
                              height: 10,
                            ),
                          ciInput(),
                          SizedBox(
                            height: 20,
                          ),
                          complementInput(),
                          SizedBox(
                            height: 30,
                          ),
                          loginButton(context),
                          SizedBox(
                            height: 15,
                          ),
                          contactsButton(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextFormField ciInput() {
    return TextFormField(
      // autofocus: true,
      controller: _ci,
      enabled: !_loading,
      decoration: InputDecoration(
        labelText: 'Cédula de Identidad',
        contentPadding: const EdgeInsets.all(0),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value.isEmpty) {
          return 'Debe llenar este campo';
        }
        return null;
      },
    );
  }

  TextFormField complementInput() {
    final regExp = RegExp(r'(^[a-zA-Z0-9]*$)');

    return TextFormField(
      controller: _complement,
      enabled: !_loading,
      onFieldSubmitted: (value) => _login(),
      decoration: InputDecoration(
        labelText: 'Complemento de C.I.',
        contentPadding: const EdgeInsets.all(0),
      ),
      textCapitalization: TextCapitalization.characters,
      validator: (value) {
        if (value.isNotEmpty) {
          if (!regExp.hasMatch(value)) {
            return 'Solo se permiten números y letras';
          }
        }
        return null;
      },
    );
  }

  FlatButton contactsButton(BuildContext context) {
    return FlatButton(
      onPressed: _loading ? null : () => gotoContacts(context),
      child: Text(
        'Contactos a nivel nacional',
        style: TextStyle(
          color: _loading ? Colors.grey : Colors.green,
          shadows: [
            Shadow(
              blurRadius: 1,
              color: Colors.grey[300],
              offset: Offset(
                1,
                1,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Object> gotoContacts(BuildContext context) {
    return Navigator.of(context).pushNamed('/contacts');
  }

  Container logoImage() {
    MediaApp _media = MediaApp(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 0.09 * _media.screenHeight,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green[800],
            Colors.grey[900],
          ],
        ),
      ),
      child: SvgPicture.asset(
        'assets/images/muserpol-logo.svg',
        width: 300,
      ),
    );
  }

  RaisedButton loginButton(BuildContext context) {
    return RaisedButton(
      onPressed: _loading ? null : () => _login(),
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      elevation: 7,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ingresar',
          ),
          if (_loading)
            Container(
              height: 20,
              width: 20,
              margin: const EdgeInsets.only(left: 20),
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }

  String fillUserName() {
    String username = _ci.text;
    if (_complement.text.isNotEmpty) {
      username += '-' + _complement.text;
    }
    return username;
  }

  void _login() {
    if (!_loading) {
      if (_loginForm.currentState.validate()) {
        String username = fillUserName();
        // TODO: Login
        setState(() {
          _loading = true;
          _error = '';
        });
      }
    }
  }
}
