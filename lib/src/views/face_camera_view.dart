import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/camera_service.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:muserpol_app/src/services/login_service.dart';
import 'package:muserpol_app/src/services/message_service.dart';
import 'package:muserpol_app/src/services/utils.dart';
import 'package:wakelock/wakelock.dart';

class FaceCameraView extends StatefulWidget {
  @override
  _FaceCameraViewState createState() => _FaceCameraViewState();
}

class _FaceCameraViewState extends State<FaceCameraView> {
  PictureController _pictureController;
  String _title = '';
  String _message = '';
  bool _messageError;
  int _currentAction;
  bool _busy;
  bool _enableButton;
  String _extPath;
  bool _loading;

  @override
  void initState() {
    Wakelock.enable();
    _messageError = false;
    _loading = true;
    _enableButton = false;
    _busy = false;
    _pictureController = new PictureController();
    _currentAction = 0;
    _getExtPath();
    super.initState();
    _getBeforeMessage();
  }

  void _getBeforeMessage() async {
    try {
      setState(() {
        _loading = true;
      });
      ApiResponse response = await MessageService.getBeforeLiveness();
      setState(() {
        _title = response.data['title'];
        _message = response.data['content'];
      });
    } catch (e) {
      print(e);
      setState(() {
        _title = 'Error de conexión';
        _message = 'No se puede conectar con el servidor de MUSERPOL';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    Wakelock.disable();
    _loading = false;
    _currentAction = 0;
    _pictureController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title.toUpperCase(),
          style: TextStyle(
            color: _messageError ? Colors.yellowAccent : Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          _loading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                      ),
                      child: LinearProgressIndicator(),
                    ),
                    Text('Analizando...'),
                  ],
                )
              : cameraAwesomePreview(),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(5),
              child: Text(
                _message,
                style: TextStyle(
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      color: Colors.grey,
                      offset: Offset(1, 1),
                      blurRadius: 1.5,
                    )
                  ],
                ),
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 60,
              margin: const EdgeInsets.only(
                bottom: 15,
                left: 10,
                right: 10,
              ),
              child: ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey;
                    } else {
                      return Colors.blue;
                    }
                  }),
                ),
                icon: Icon(
                    _currentAction == 0 ? Icons.not_started : Icons.camera_alt),
                onPressed: (_busy || !_enableButton)
                    ? null
                    : (() => (_currentAction == 0)
                        ? _getLivenessActions(context)
                        : _takePicture(context)),
                label: Text(
                  _currentAction == 0 ? 'INICIAR' : 'CAPTURAR',
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _getExtPath() async {
    _extPath = await Utils.getDir('faces');
    Utils.removeDir(
      _extPath,
      recreate: true,
    );
  }

  void _takePicture(BuildContext context) async {
    try {
      setState(() {
        _busy = true;
      });
      Utils.createDir(_extPath);
      String filePath = _extPath +
          DateTime.now().toUtc().millisecondsSinceEpoch.toString() +
          '.jpg';
      await _pictureController.takePicture(filePath);
      setState(() {
        _loading = true;
      });
      _sendImage(context, filePath);
    } catch (e) {
      print(e);
      _takePicture(context);
    }
  }

  void _sendImage(BuildContext context, String filePath) async {
    File file = File(filePath);
    try {
      Uint8List image = await file.readAsBytes();
      String imageString = base64.encode(image);
      ApiResponse response = await CameraService.sendImage(imageString);
      setState(() {
        _title = response.message;
      });
      if (!response.data['completed']) {
        if (_message == response.data['action']['message']) {
          setState(() {
            _messageError = true;
          });
        } else {
          setState(() {
            _messageError = false;
          });
        }
        setState(() {
          _message = response.data['action']['message'];
          _currentAction = response.data['current_action'];
        });
      } else {
        if (response.data['type'] == 'enroll') {
          LoginService.enroll(
            context,
            message: response.message,
          );
        } else {
          Navigator.of(context).pushReplacementNamed(
            Config.routes['economic_complement_create'],
          );
        }
      }
      setState(() {
        _busy = false;
      });
    } catch (e) {
      setState(() {
        _title = 'Intente nuevamente';
        _busy = false;
      });
    } finally {
      file.delete();
      setState(() {
        _loading = false;
      });
    }
  }

  void _getLivenessActions(BuildContext context) async {
    try {
      ApiResponse response = await CameraService.getLivenessActions();
      if (response.code == 200 && response.data != null) {
        setState(() {
          _title = response.message;
          _message = response.data['action']['message'];
          _currentAction = response.data['current_action'];
        });
        _showDialog(context, response.data['dialog']);
      } else {
        _title = 'Error de conexión';
        _message =
            'No se puede realizar la operación en este momento, intente mas tarde.';
      }
    } catch (e) {
      _title = 'Error de conexión';
      _message =
          'No se puede realizar la operación en este momento, intente mas tarde.';
    }
  }

  Widget cameraAwesomePreview() {
    return CameraAwesome(
      brightness: ValueNotifier<double>(1),
      testMode: false,
      enableAudio: ValueNotifier<bool>(false),
      captureMode: ValueNotifier(CaptureModes.PHOTO),
      sensor: ValueNotifier(Sensors.FRONT),
      switchFlashMode: ValueNotifier(CameraFlashes.NONE),
      orientation: DeviceOrientation.portraitUp,
      zoom: ValueNotifier<double>(0),
      fitted: false,
      photoSize: ValueNotifier(null),
      selectDefaultSize: (List<Size> availableSizes) => Size(320, 240),
      onCameraStarted: () async {
        double diskSpace = 0;
        diskSpace = await DiskSpace.getFreeDiskSpace;
        // Al menos debe tener 2 MB de espacio disponible
        if (diskSpace < 2) {
          setState(() {
            _message = 'Debe liberar espacio de memoria';
            _enableButton = false;
          });
        } else {
          setState(() {
            _enableButton = true;
          });
        }
      },
    );
  }

  void _showDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            data['title'].toString().toUpperCase(),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text(
              data['content'],
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
}
