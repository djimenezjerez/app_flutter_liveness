import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:audioplayers/audio_cache.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/camera_service.dart';
import 'package:muserpol_app/src/services/login_service.dart';
import 'package:muserpol_app/src/services/media_app.dart';
import 'package:path_provider/path_provider.dart';
import 'package:loading_overlay/loading_overlay.dart';

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  PictureController _pictureController;
  String _title;
  String _message;
  int _currentAction;
  bool _busy;

  @override
  void initState() {
    _busy = false;
    _pictureController = new PictureController();
    _title = 'Control de Vivencia';
    _message = 'Siga las instrucciones, para comenzar presione el botón azul';
    _currentAction = 0;
    super.initState();
  }

  @override
  void dispose() {
    _currentAction = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _media = MediaApp(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
        ),
      ),
      body: LoadingOverlay(
        isLoading: _busy,
        color: Colors.green,
        child: Stack(
          children: [
            cameraAwesomePreview(),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.all(5),
                child: Text(
                  _message,
                  style: TextStyle(
                    fontSize: _media.screenHeight * 0.0335,
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
                child: ElevatedButton.icon(
                  icon: Icon(_currentAction == 0
                      ? Icons.not_started
                      : Icons.camera_alt),
                  onPressed: _busy
                      ? null
                      : (() => (_currentAction == 0)
                          ? _getLivenessActions(context)
                          : _takePicture(context)),
                  label: Text(
                    _currentAction == 0 ? 'Iniciar' : 'Capturar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _media.screenHeight * 0.035,
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
            ),
          ],
        ),
      ),
    );
  }

  void _takePicture(BuildContext context) async {
    try {
      setState(() {
        _busy = true;
      });
      final externalDirectory = await getExternalStorageDirectory();
      final extPath = externalDirectory.path + '/faces/';
      if (Directory(extPath).existsSync()) {
        Directory(extPath).deleteSync(
          recursive: true,
        );
      } else {
        Directory(extPath).createSync();
      }
      String filePath = extPath +
          DateTime.now().toUtc().millisecondsSinceEpoch.toString() +
          '.jpg';
      await _pictureController.takePicture(filePath);
      _sendImage(context, filePath);
    } catch (e) {
      _takePicture(context);
    }
  }

  void _sendImage(BuildContext context, String filePath) async {
    try {
      _playAudio('audio/camera-shutter.mp3');
      File file = File(filePath);
      Uint8List image = await file.readAsBytes();
      String imageString = base64.encode(image);
      ApiResponse response = await CameraService.sendImage(imageString);
      setState(() {
        _title = response.message;
      });
      if (!response.data['completed']) {
        if (_message == response.data['action']['message']) {
          _playAudio('audio/error.mp3');
        } else {
          _playAudio('audio/success.mp3');
        }
        setState(() {
          _message = response.data['action']['message'];
          _currentAction = response.data['current_action'];
        });
      } else {
        _playAudio('audio/success.mp3');
        setState(() {
          _message = '';
        });
        _showDialog(
          context,
          {
            'title': 'Proceso completado',
            'content': 'Puede proceder a la siguiente sección.',
          },
        );
        LoginService.enroll(context);
      }
      setState(() {
        _busy = false;
      });
    } catch (e) {
      setState(() {
        _title = 'Intente nuevamente';
        _busy = false;
      });
    }
  }

  void _playAudio(String file) {
    AudioCache cache = new AudioCache();
    cache.play(file);
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
    );
  }

  void _showDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(data['title']),
          content: Text(data['content']),
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
