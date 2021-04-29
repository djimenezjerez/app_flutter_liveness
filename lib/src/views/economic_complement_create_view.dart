import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/eco_com_procedure_service.dart';
import 'package:muserpol_app/src/services/economic_complement_service.dart';
import 'package:muserpol_app/src/services/liveness_service.dart';
import 'package:muserpol_app/src/services/utils.dart';
import 'package:muserpol_app/src/views/card_view.dart';
import 'package:muserpol_app/src/views/economic_complements_view.dart';

class EconomicComplementCreateView extends StatefulWidget {
  @override
  _EconomicComplementCreateViewState createState() =>
      _EconomicComplementCreateViewState();
}

class _EconomicComplementCreateViewState
    extends State<EconomicComplementCreateView> {
  final ScrollController _scrollButtonController = ScrollController();
  final ScrollController _scrollImageController = ScrollController();
  final picker = ImagePicker();
  final List<String> _attachments = [
    'Boleta de renta',
    'C.I. Anverso',
    'C.I. Reverso',
  ];
  List<File> _images;
  bool _loading;
  bool _validate;
  int _ecoComProcedureId;
  dynamic _procedure;
  String _extPath;
  bool _enableSendButton;

  @override
  void initState() {
    _enableSendButton = false;
    _loading = true;
    _validate = false;
    _images = [
      null,
      null,
      null,
    ];
    _getAffiliateEnabled();
    super.initState();
  }

  @override
  void dispose() {
    _getExtPath();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complemento Económico'),
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
                            color: Colors.green[100],
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
                              'Tome una fotografía legible de:',
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
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: ElevatedButton.icon(
                                    onPressed: () => _getImage(0),
                                    icon: Icon(Icons.account_balance),
                                    label: Text(_attachments[0]),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.orange[600],
                                      elevation: 5,
                                    ),
                                  ),
                                ),
                                if (!_validate)
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: ElevatedButton.icon(
                                      onPressed: () => _getImage(1),
                                      icon: Icon(Icons.account_box),
                                      label: Text(_attachments[1]),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.teal,
                                        elevation: 5,
                                      ),
                                    ),
                                  ),
                                if (!_validate)
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: ElevatedButton.icon(
                                      onPressed: () => _getImage(2),
                                      icon: Icon(Icons.analytics_outlined),
                                      label: Text(_attachments[2]),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.blueGrey,
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
                                if (_images[0] != null)
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 3,
                                        color: Colors.orange[600],
                                      ),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    height: 250,
                                    child: Image.file(
                                      _images[0],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                if (_images[1] != null)
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 3,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    height: 250,
                                    child: Image.file(
                                      _images[1],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                if (_images[2] != null)
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 3,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    height: 250,
                                    child: Image.file(
                                      _images[2],
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
                    child: ElevatedButton.icon(
                      onPressed:
                          _enableSendButton ? () => _saveProcedure() : null,
                      icon: Icon(Icons.send),
                      label: Text('Enviar'),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  void _getExtPath() async {
    _extPath = await Utils.getDir('Pictures');
    Utils.removeDir(
      _extPath,
      recreate: true,
    );
  }

  void _getAffiliateEnabled() async {
    try {
      _getExtPath();
      ApiResponse response = await LivenessService.getAffiliateEnabled();
      setState(() {
        _validate = response.data['validate'];
        _ecoComProcedureId = response.data['procedure_id'];
      });
      _getEcoComProcedure(response.data['procedure_id']);
    } catch (e) {
      print(e);
      _loading = false;
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

  void _getImage(int index) async {
    try {
      if (_images[index] != null) _images[index].delete();
      final pickedFile = await picker.getImage(
        source: ImageSource.camera,
        maxWidth: 640,
        maxHeight: 480,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (pickedFile != null) {
        _scrollButtonToEnd();
        setState(() {
          _images[index] = File(pickedFile.path);
        });
        if ((_images[0] != null && _validate) ||
            (_images.where((i) => i == null).length == 0 && !_validate)) {
          _enableSendButton = true;
        } else {
          _enableSendButton = false;
        }
      }
    } catch (e) {
      print(e);
    } finally {
      _scrollImageToEnd();
    }
  }

  void _saveProcedure() async {
    List<Map<String, String>> files = [];
    for (int i = 0; i < (_validate ? 1 : 3); i++) {
      Uint8List image = await _images[i].readAsBytes();
      String imageString = base64.encode(image);
      files.add({
        'filename': _attachments[i]
                .replaceAll('.', '')
                .replaceAll(' ', '_')
                .toLowerCase() +
            '_' +
            _ecoComProcedureId.toString() +
            '.jpg',
        'content': imageString,
      });
    }
    ApiResponse response =
        await EconomicComplementService.storeEconomicComplement(
            files, _ecoComProcedureId);
    if (response.code == 200) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => EconomicComplementsView(
            dialogMessage: response.message,
          ),
        ),
      );
    } else {
      _showDialog(response.message);
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ocurrió un error'),
          content: Text(message),
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
