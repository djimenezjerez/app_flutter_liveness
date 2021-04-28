import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/eco_com_procedure_service.dart';
import 'package:muserpol_app/src/services/liveness_service.dart';
import 'package:muserpol_app/src/services/utils.dart';
import 'package:muserpol_app/src/views/card_view.dart';

class EconomicComplementCreateView extends StatefulWidget {
  @override
  _EconomicComplementCreateViewState createState() =>
      _EconomicComplementCreateViewState();
}

class _EconomicComplementCreateViewState
    extends State<EconomicComplementCreateView> {
  final picker = ImagePicker();
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
    _images.forEach((image) {
      if (image != null) image.delete();
    });
    super.dispose();
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
                              'Tome una fotografía de:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: ElevatedButton.icon(
                                    onPressed: () => _getImage(0),
                                    icon: Icon(Icons.account_balance),
                                    label: Text('Boleta'),
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
                                      label: Text('C.I. Anverso'),
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
                                      label: Text('C.I. Reverso'),
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
    }
  }

  void _saveProcedure() {
    print(_ecoComProcedureId);
  }
}
