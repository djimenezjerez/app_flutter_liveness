import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_ml_vision/flutter_camera_ml_vision.dart';
import 'package:muserpol_app/src/services/media_app.dart';
import 'package:path_provider/path_provider.dart';

class SelfieView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reconocimiento Facial',
        ),
      ),
      body: CameraContainer(),
    );
  }
}

class CameraContainer extends StatefulWidget {
  @override
  _CameraContainerState createState() => _CameraContainerState();
}

class _CameraContainerState extends State<CameraContainer> {
  bool _counterEnabled = false;
  bool _enrolled = false;
  Timer _timer;
  List<Map<String, dynamic>> _orders = [
    {
      'step': 1,
      'label': 'MIRE A LA DERECHA',
      'count': 0,
    },
    {
      'step': 2,
      'label': 'MIRE A LA IZQUIERDA',
      'count': 0,
    },
    {
      'step': 3,
      'label': 'MIRE AL FRENTE',
      'count': 0,
    },
    {
      'step': 4,
      'label': 'SONRÍA',
      'count': 0,
    }
  ];
  Map<String, dynamic> _currentOrder;
  Face _face;
  final _scanKey = GlobalKey<CameraMlVisionState>();
  final CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  final FaceDetector detector = FirebaseVision.instance.faceDetector(
    FaceDetectorOptions(
      enableClassification: true,
      minFaceSize: 1,
      mode: FaceDetectorMode.accurate,
    ),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaApp _media = MediaApp(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.symmetric(
              vertical: _media.screenHeight * 0.01,
              horizontal: _media.screenWidth * 0.05,
            ),
            child: titleSpan()),
        Flexible(
          fit: FlexFit.tight,
          child: CameraMlVision<List<Face>>(
            key: _scanKey,
            cameraLensDirection: cameraLensDirection,
            detector: detector.processImage,
            resolution: ResolutionPreset.high,
            overlayBuilder: (context) {
              return CustomPaint(
                painter: FaceDetectorPainter(
                  _scanKey.currentState.cameraValue.previewSize.flipped,
                  _face,
                  reflection: cameraLensDirection == CameraLensDirection.front,
                ),
              );
            },
            onResult: (faces) {
              if (faces == null || faces.isEmpty || !mounted) {
                return;
              }
              Face face;
              if (faces.length == 1) {
                face = faces[0];
              } else if (faces.length > 1) {
                faces.asMap().forEach((int index, Face _face) {
                  if (index > 0 && _face != null) {
                    if (_face.boundingBox.width > face.boundingBox.width &&
                        _face.boundingBox.height > face.boundingBox.height) {
                      face = _face;
                    }
                  } else {
                    face = _face;
                  }
                });
              }
              if (face != null) {
                if (face.boundingBox.width > 0) {
                  if (face.headEulerAngleY != 0 &&
                      face.headEulerAngleZ != 0 &&
                      face.leftEyeOpenProbability != null &&
                      face.rightEyeOpenProbability != null &&
                      face.smilingProbability != null) {
                    setState(() {
                      _face = face;
                    });
                  }
                }
              }
            },
            onDispose: () {
              detector.close();
            },
          ),
        ),
        bottomButton(_media)
      ],
    );
  }

  Widget titleSpan() {
    if (_currentOrder == null) {
      return Column(
        children: [
          Text(
            'Siga las instrucciones de esta sección',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.red,
              shadows: [
                Shadow(
                  color: Colors.grey,
                  offset: Offset(1.5, 1.5),
                  blurRadius: 1,
                )
              ],
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            ' Presione el botón azul para iniciar',
            style: TextStyle(
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return Text(
        _currentOrder['label'],
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.red,
          shadows: [
            Shadow(
              color: Colors.grey,
              offset: Offset(1.5, 1.5),
              blurRadius: 1,
            )
          ],
        ),
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startCounter() async {
    setState(() {
      _timer = Timer.periodic(
        Duration(
          seconds: 5,
        ),
        (t) => takePicture(),
      );
      _currentOrder = _orders[0];
      _counterEnabled = true;
    });
  }

  void takePicture() async {
    Directory appDir = await getExternalStorageDirectory();
    String picturePath =
        '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    print(picturePath);
    await _scanKey.currentState.takePicture(picturePath);
    print('Foto obtenida');
  }

  Widget bottomButton(MediaApp media) {
    if (!_enrolled && !_counterEnabled) {
      return Container(
        width: media.screenWidth,
        child: RaisedButton(
          onPressed: () => startCounter(),
          color: Colors.blue[800],
          textColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 35,
                ),
                SizedBox(
                  width: 15,
                ),
                Flexible(
                  child: Text(
                    'Iniciar',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (!_enrolled && _counterEnabled) {
      // TODO: botón para terminar
      return Container();
    } else {
      // TODO: botón para reintentar
      return Container();
    }
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.imageSize,
    this.face, {
    this.reflection = false,
  });

  final bool reflection;
  final Size imageSize;
  final Face face;

  @override
  void paint(Canvas canvas, Size size) {
    if (face != null) {
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Colors.green[800];

      final faceRect = _reflectionRect(
        reflection,
        face.boundingBox,
        imageSize.width,
      );

      canvas.drawRect(
        _scaleRect(
          rect: faceRect,
          imageSize: imageSize,
          widgetSize: size,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.face != face;
  }
}

Rect _reflectionRect(bool reflection, Rect boundingBox, double width) {
  if (!reflection) {
    return boundingBox;
  }
  final centerX = width / 2;
  final left = ((boundingBox.left - centerX) * -1) + centerX;
  final right = ((boundingBox.right - centerX) * -1) + centerX;
  return Rect.fromLTRB(left, boundingBox.top, right, boundingBox.bottom);
}

Rect _scaleRect({
  @required Rect rect,
  @required Size imageSize,
  @required Size widgetSize,
}) {
  final scaleX = widgetSize.width / imageSize.width;
  final scaleY = widgetSize.height / imageSize.height;
  final scaledRect = Rect.fromLTRB(
    rect.left.toDouble() * scaleX,
    rect.top.toDouble() * scaleY,
    rect.right.toDouble() * scaleX,
    rect.bottom.toDouble() * scaleY,
  );

  return scaledRect;
}
