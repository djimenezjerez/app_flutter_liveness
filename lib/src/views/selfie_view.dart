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
          child: Text(
            'Coincida el punto amarillo con la punta de su nariz',
            style: TextStyle(
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
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
                child: Center(
                  child: Icon(
                    Icons.circle,
                    color: Colors.yellow,
                    size: 8,
                  ),
                ),
              );
            },
            onResult: (faces) {
              if (faces == null || faces.isEmpty || !mounted) {
                return;
              }
              if (faces.length == 1) {
                if (faces[0].headEulerAngleY != 0 &&
                    faces[0].headEulerAngleZ != 0 &&
                    faces[0].leftEyeOpenProbability != null &&
                    faces[0].rightEyeOpenProbability != null &&
                    faces[0].smilingProbability != null) {
                  setState(() {
                    _faces = faces;
                  });
                }
              }
            },
            onDispose: () {
              detector.close();
            },
          ),
        ),
      ],
    );
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
