import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muserpol_app/src/services/utils.dart';
import 'package:wakelock/wakelock.dart';

class AttachmentCameraView extends StatefulWidget {
  final String title;
  final String filename;
  final Function setLoading;

  const AttachmentCameraView({
    Key key,
    @required this.title,
    @required this.filename,
    @required this.setLoading,
  }) : super(key: key);

  @override
  _AttachmentCameraViewState createState() => _AttachmentCameraViewState();
}

class _AttachmentCameraViewState extends State<AttachmentCameraView> {
  PictureController _pictureController;
  bool _enableButton;
  String _extPath;

  @override
  void initState() {
    Wakelock.enable();
    _enableButton = false;
    _pictureController = new PictureController();
    _getExtPath();
    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();
    _enableButton = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          cameraAwesomePreview(),
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
                icon: Icon(Icons.camera_alt),
                onPressed: _enableButton ? (() => _takePicture(context)) : null,
                label: Text(
                  'CAPTURAR',
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

  Widget cameraAwesomePreview() {
    return CameraAwesome(
      brightness: ValueNotifier<double>(1),
      testMode: false,
      enableAudio: ValueNotifier<bool>(false),
      captureMode: ValueNotifier(CaptureModes.PHOTO),
      sensor: ValueNotifier(Sensors.BACK),
      switchFlashMode: ValueNotifier(CameraFlashes.NONE),
      orientation: DeviceOrientation.portraitUp,
      zoom: ValueNotifier<double>(0),
      fitted: false,
      photoSize: ValueNotifier(null),
      selectDefaultSize: (List<Size> availableSizes) => Size(640, 480),
      onCameraStarted: () {
        setState(() {
          _enableButton = true;
        });
      },
    );
  }

  void _getExtPath() async {
    _extPath = await Utils.getDir('attachments');
  }

  void _takePicture(BuildContext context) async {
    try {
      setState(() {
        _enableButton = true;
      });
      Utils.createDir(_extPath);
      String filePath = _extPath + widget.filename;
      if (File(filePath).existsSync()) {
        File(filePath).deleteSync();
      }
      await _pictureController.takePicture(filePath);
      widget.setLoading(false);
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
      _takePicture(context);
    }
  }
}
