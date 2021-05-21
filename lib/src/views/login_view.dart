import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:muserpol_app/src/services/login_service.dart';
import 'package:muserpol_app/src/services/media_app.dart';
import 'package:dropdown_date_picker/dropdown_date_picker.dart';
import 'package:muserpol_app/src/services/utils.dart';

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
  bool _dateError = false;

  static final now = DateTime.now();

  final dropdownDatePicker = DropdownDatePicker(
    firstDate: ValidDate(
      year: now.year - 100,
      month: 1,
      day: 1,
    ),
    lastDate: ValidDate(
      year: now.year - 18,
      month: now.month,
      day: now.day,
    ),
    dateFormat: DateFormat.dmy,
    dropdownColor: Colors.green[100],
    dateHint: DateHint(
      year: 'Año',
      month: 'Mes',
      day: 'Día',
    ),
    ascending: true,
  );

  @override
  Widget build(BuildContext context) {
    MediaApp _media = MediaApp(context);

    return Scaffold(
      body: Stack(
        children: [
          LogoImage(context: context, media: _media),
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
                    left: _media.screenWidth * 0.1,
                    right: _media.screenWidth * 0.1,
                    top: _media.screenHeight * 0.5,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 20,
                    ),
                    child: Form(
                      key: _loginForm,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Config.appName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: _media.screenHeight * 0.03,
                              color: Colors.green[800],
                              shadows: [
                                Shadow(
                                  color: Colors.grey,
                                  offset: Offset(1, 1),
                                  blurRadius: 1.5,
                                )
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          if (_error != '')
                            Text(
                              _error,
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (_error != '')
                            SizedBox(
                              height: 10,
                            ),
                          Text(
                            'Fecha de nacimiento',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          dropdownDatePicker,
                          if (_dateError)
                            Text(
                              'Debe llenar este campo',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red[600],
                              ),
                            ),
                          SizedBox(
                            height: 20,
                          ),
                          CiInput(
                            ci: _ci,
                            loading: _loading,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          complementInput(context),
                          SizedBox(
                            height: 30,
                          ),
                          loginButton(context),
                          SizedBox(
                            height: 30,
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

  TextFormField complementInput(BuildContext context) {
    final regExp = RegExp(r'(^[a-zA-Z0-9]*$)');

    return TextFormField(
      autofocus: false,
      controller: _complement,
      enabled: !_loading,
      onFieldSubmitted: (value) => _login(context),
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

  TextButton contactsButton(BuildContext context) {
    return TextButton(
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
    return Navigator.of(context).pushNamed(Config.routes['contacts']);
  }

  ElevatedButton loginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _loading ? null : () => _login(context),
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).primaryColor,
        onPrimary: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: 8,
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
            Text(
              'INGRESAR',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            if (_loading)
              Container(
                height: 20,
                width: 20,
                margin: const EdgeInsets.only(
                  left: 20,
                ),
                child: CircularProgressIndicator(),
              )
          ],
        ),
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

  void _login(BuildContext context) async {
    if (!_loading) {
      try {
        if (dropdownDatePicker.day == null ||
            dropdownDatePicker.month == null ||
            dropdownDatePicker.year == null) {
          setState(() {
            _dateError = true;
          });
          return;
        } else {
          setState(() {
            _dateError = false;
          });
        }
        if (_loginForm.currentState.validate() && !_dateError) {
          bool granted = await Utils.verifyPermissions();
          if (granted) {
            String username = fillUserName();
            _loading = true;
            setState(() {
              _error = '';
            });
            var res = await LoginService.login(
              username,
              dropdownDatePicker.getDate('-'),
            );
            _loading = false;

            if (res.code == 200) {
              LoginService.setUserData(context, res.data);
            } else if ([400, 401, 403, 404, 500].contains(res.code)) {
              setState(() => _error = res.message);
            } else {
              setState(() => _error = 'Debe habilitar el acceso a Internet');
            }
          } else {
            setState(() => _error = 'Permisos insuficientes');
          }
        }
      } catch (e) {
        setState(() => _error = 'Conexión inestable');
      }
    }
  }
}

class CiInput extends StatelessWidget {
  const CiInput({
    Key key,
    @required TextEditingController ci,
    @required bool loading,
  })  : ci = ci,
        loading = loading,
        super(key: key);

  final TextEditingController ci;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: false,
      controller: ci,
      enabled: !loading,
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
        } else if (value.length < 5) {
          return 'Ingrese al menos 5 dígitos';
        }
        return null;
      },
    );
  }
}

class LogoImage extends StatelessWidget {
  const LogoImage({
    Key key,
    @required this.context,
    @required this.media,
  }) : super(key: key);

  final BuildContext context;
  final MediaApp media;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: media.screenHeight * 0.09,
      ),
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
      child: Image(
        image: AssetImage(
          'assets/images/muserpol-logo.png',
        ),
        repeat: ImageRepeat.noRepeat,
        alignment: Alignment.center,
        height: media.screenHeight * 0.17,
      ),
    );
  }
}
