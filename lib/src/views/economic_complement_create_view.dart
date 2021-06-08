import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/eco_com_procedure_service.dart';
import 'package:muserpol_app/src/services/economic_complement_service.dart';
import 'package:muserpol_app/src/services/liveness_service.dart';
import 'package:muserpol_app/src/services/utils.dart';
import 'package:muserpol_app/src/views/attachment_camera_view.dart';
import 'package:muserpol_app/src/views/card_view.dart';
import 'package:muserpol_app/src/views/economic_complements_view.dart';
import 'package:open_file/open_file.dart';

class EconomicComplementCreateView extends StatefulWidget {
  @override
  _EconomicComplementCreateViewState createState() =>
      _EconomicComplementCreateViewState();
}

class _EconomicComplementCreateViewState
    extends State<EconomicComplementCreateView> {
  final ScrollController _scrollButtonController = ScrollController();
  final ScrollController _scrollImageController = ScrollController();
  List<Map<String, dynamic>> _attachments = [
    {
      'title': 'Boleta de Renta',
      'color': Colors.orange[600],
      'icon': Icons.account_balance,
      'filename': 'boleta_de_renta.jpg',
    },
    {
      'title': 'C.I. Anverso',
      'color': Colors.teal,
      'icon': Icons.account_box,
      'filename': 'ci_anverso.jpg',
    },
    {
      'title': 'C.I. Reverso',
      'color': Colors.blueGrey,
      'icon': Icons.account_box_outlined,
      'filename': 'ci_reverso.jpg',
    }
  ];
  bool _loading;
  bool _validate;
  int _ecoComProcedureId;
  dynamic _procedure;
  String _extPath;
  String _month;
  bool _enableSendButton;
  final _procedureForm = GlobalKey<FormState>();
  final _phone = TextEditingController();

  @override
  void initState() {
    _month = '';
    _enableSendButton = false;
    _loading = true;
    _validate = false;
    _getAffiliateEnabled();
    _getExtPath();
    super.initState();
  }

  @override
  void dispose() {
    _getExtPath();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complemento Económico'.toUpperCase()),
      ),
      body: Container(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CardView(
                            data: _procedure,
                            setLoading: setLoading,
                            color: Colors.green[200],
                          ),
                          Card(
                            color: Colors.green[100],
                            elevation: 5,
                            margin: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                  ),
                                  child: Text(
                                    'Datos requeridos'.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Table(
                                  border: TableBorder(
                                    horizontalInside: BorderSide(
                                      width: 0.5,
                                      color: Colors.grey,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  children: [
                                    TableRow(
                                      children: [
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.top,
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                              bottom: 2,
                                              top: 15,
                                            ),
                                            child: Text(
                                              'Celular:',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.top,
                                          child: Container(
                                            padding: const EdgeInsets.all(0),
                                            child: Form(
                                              key: _procedureForm,
                                              autovalidateMode:
                                                  AutovalidateMode.always,
                                              child: PhoneInput(
                                                phone: _phone,
                                                loading: _loading,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 10,
                            thickness: 2,
                            indent: 10,
                            endIndent: 10,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              _getTextCamera(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollButtonController,
                            child: Row(
                              children: [
                                for (int i = 0; i < _attachments.length; i++)
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: ElevatedButton.icon(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AttachmentCameraView(
                                            title: _attachments[i]['title'],
                                            filename: _attachments[i]
                                                ['filename'],
                                            setLoading: setLoading,
                                          ),
                                        ),
                                      ),
                                      icon: File(_extPath +
                                                  _attachments[i]['filename'])
                                              .existsSync()
                                          ? Icon(Icons.check)
                                          : Icon(_attachments[i]['icon']),
                                      label: Text(_attachments[i]['title']),
                                      style: ElevatedButton.styleFrom(
                                        primary: _attachments[i]['color'],
                                        elevation: 5,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 10,
                            thickness: 2,
                            indent: 10,
                            endIndent: 10,
                          ),
                          SingleChildScrollView(
                            controller: _scrollImageController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (int i = 0; i < _attachments.length; i++)
                                  if (File(_extPath +
                                          _attachments[i]['filename'])
                                      .existsSync())
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 3,
                                          color: _attachments[i]['color'],
                                        ),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      height: 150,
                                      child: Image.file(
                                        File(_extPath +
                                            _attachments[i]['filename']),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 60,
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 0,
                        padding: const EdgeInsets.all(0),
                      ),
                      onPressed:
                          _enableSendButton ? () => _saveProcedure() : null,
                      icon: Icon(Icons.send),
                      label: Text(
                        'ENVIAR',
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _getTextCamera() {
    String text = 'Tome';
    if (!_validate) {
      text += ' fotografías legibles de';
    } else {
      text += ' una fotografía legible de';
    }
    if (_month != '') text += ' la boleta del mes de ' + _month;
    if (!_validate) text += ' y del C.I.';
    text += ':';
    return text.toUpperCase();
  }

  void _getExtPath() async {
    _extPath = await Utils.getDir('attachments');
  }

  void _getAffiliateEnabled() async {
    try {
      _getExtPath();
      ApiResponse response = await LivenessService.getAffiliateEnabled();
      if (response.data['cell_phone_number'].isNotEmpty) {
        _phone.text = response.data['cell_phone_number'][0];
      }
      setState(() {
        _validate = response.data['validate'];
        _ecoComProcedureId = response.data['procedure_id'];
        _month = response.data['month'];
      });
      if (_validate) {
        _attachments = [_attachments[0]];
      }
      _getEcoComProcedure(response.data['procedure_id']);
    } catch (e) {
      print(e);
      _loading = false;
    } finally {
      _validateImages();
    }
  }

  void _getEcoComProcedure(ecoComProcedureId) async {
    try {
      ApiResponse response =
          await EcoComProcedureService.getEcoComProcedure(ecoComProcedureId);
      setState(() {
        _procedure = response.data;
      });
    } catch (e) {
      print(e);
    } finally {
      _loading = false;
    }
  }

  void _saveProcedure() async {
    try {
      setState(() {
        _enableSendButton = false;
        _loading = true;
      });
      if (_procedureForm.currentState.validate()) {
        List<Map<String, String>> files = [];
        for (int i = 0; i < (_validate ? 1 : 3); i++) {
          Uint8List image =
              File(_extPath + _attachments[i]['filename']).readAsBytesSync();
          String imageString = base64.encode(image);
          files.add({
            'filename': _ecoComProcedureId.toString() +
                '_' +
                _attachments[i]['filename'],
            'content': imageString,
          });
        }
        var response = await EconomicComplementService.storeEconomicComplement(
            files, int.parse(_phone.text), _ecoComProcedureId);
        if (response.runtimeType == ApiResponse) {
          _showDialog(response.message == null
              ? 'Comuníquese con MUSERPOL para informar acerca de este error.'
              : response.message);
        } else {
          String file = await Utils.saveFile(
              'Documents',
              'sol_eco_com_' +
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  '.pdf',
              response);
          await OpenFile.open(file);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => EconomicComplementsView(
                dialogMessage: 'Solicitud realizada exitosamente.',
              ),
            ),
            (Route<dynamic> route) => false,
          );
          Utils.removeDir(
            _extPath,
            recreate: true,
          );
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _enableSendButton = true;
        _loading = false;
      });
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'OCURRIÓ UN ERROR',
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text(
              message,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
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

  void _scrollButtonToEnd() {
    if (_scrollButtonController.hasClients) {
      var scrollPosition = _scrollButtonController.position;
      if (scrollPosition.maxScrollExtent > scrollPosition.minScrollExtent) {
        _scrollButtonController.animateTo(
          scrollPosition.maxScrollExtent,
          duration: new Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _scrollImageToEnd() async {
    await Future.delayed(Duration(
      milliseconds: 1000,
    ));
    if (_scrollImageController.hasClients) {
      var scrollPosition = _scrollImageController.position;
      if (scrollPosition.maxScrollExtent > scrollPosition.minScrollExtent) {
        _scrollImageController.animateTo(
          scrollPosition.maxScrollExtent,
          duration: new Duration(milliseconds: 1000),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _validateImages() {
    bool validForm = true;
    for (int i = 0; i < _attachments.length; i++) {
      validForm &= File(_extPath + _attachments[i]['filename']).existsSync();
    }
    setState(() {
      _enableSendButton = validForm;
    });
  }

  void setLoading(bool value) {
    imageCache.clear();
    _validateImages();
    setState(() {
      _loading = value;
    });
    if (!value) {
      _scrollButtonToEnd();
      _scrollImageToEnd();
    }
  }
}

class PhoneInput extends StatelessWidget {
  const PhoneInput({
    Key key,
    @required TextEditingController phone,
    @required bool loading,
  })  : phone = phone,
        loading = loading,
        super(key: key);

  final TextEditingController phone;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: false,
      controller: phone,
      enabled: !loading,
      decoration: InputDecoration(
        // labelText: 'Teléfono Celular',
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
        } else if (value[0] != '6' && value[0] != '7') {
          return 'Debe iniciar con 6 o 7';
        } else if (value.length != 8) {
          return 'Debe ingresar 8 dígitos';
        }
        return null;
      },
    );
  }
}
