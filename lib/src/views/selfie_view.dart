import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_ml_vision/flutter_camera_ml_vision.dart';
import 'package:muserpol_app/src/services/media_app.dart';

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
  List<String> _orders = [
    'MIRE A SU IZQUIERDA',
    'MIRE ARRIBA',
    'MIRE A SU DERECHA',
    'MIRE ABAJO',
    'MIRE DE FRENTE',
    'MIRE SONRIENDO',
  ];
  int _currentOrder = 0;
  List<Face> _faces = [];
  final _scanKey = GlobalKey<CameraMlVisionState>();
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  FaceDetector detector = FirebaseVision.instance.faceDetector(
    FaceDetectorOptions(
      enableClassification: true,
      minFaceSize: 1,
      mode: FaceDetectorMode.fast,
    ),
  );

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
          child: Column(
            children: [
              Text(
                _orders[_currentOrder],
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
                ' y presione el botón azul',
                style: TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: CameraMlVision<List<Face>>(
            key: _scanKey,
            cameraLensDirection: cameraLensDirection,
            detector: detector.processImage,
            resolution: ResolutionPreset.low,
            overlayBuilder: (context) {
              return CustomPaint(
                painter: FaceDetectorPainter(
                  _scanKey.currentState.cameraValue.previewSize.flipped,
                  _faces,
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
                  if (index > 0) {
                    if (_face.boundingBox.width > face.boundingBox.width &&
                        _face.boundingBox.height > face.boundingBox.height) {
                      face = _face;
                    }
                  } else {
                    face = _face;
                  }
                });
              }
              if (face.boundingBox.width > 0) {
                if (face.headEulerAngleY != 0 &&
                    face.headEulerAngleZ != 0 &&
                    face.leftEyeOpenProbability != null &&
                    face.rightEyeOpenProbability != null &&
                    face.smilingProbability != null) {
                  setState(() {
                    _faces = [face];
                  });
                }
              }
            },
            onDispose: () {
              detector.close();
            },
          ),
        ),
        Container(
          width: _media.screenWidth,
          child: RaisedButton(
            onPressed: () {
              captureImage();
            },
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
                      'Capturar',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  void captureImage() {
    setState(() {
      _currentOrder = _currentOrder + 1;
    });
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.imageSize,
    this.faces, {
    this.reflection = false,
  });

  final bool reflection;
  final Size imageSize;
  final List<Face> faces;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.green[800];

    for (Face face in faces) {
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
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
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
