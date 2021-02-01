import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:muserpol_app/src/services/selfie_service.dart';
import 'package:muserpol_app/src/utils/camera_util.dart';

class SelfieView extends StatefulWidget {
  @override
  _SelfieViewState createState() => _SelfieViewState();
}

class _SelfieViewState extends State<SelfieView> {
  DateTime _lastSent = DateTime.now();

  CameraController _camera;
  bool _isDetecting = false;
  List<Face> _faces;
  CameraLensDirection _direction = CameraLensDirection.front;
  final FaceDetector _faceDetector =
      FirebaseVision.instance.faceDetector(FaceDetectorOptions(
    enableClassification: true,
    minFaceSize: 1,
    mode: FaceDetectorMode.accurate,
  ));

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    if (_camera.value.isStreamingImages) {
      _faceDetector?.close();
      _camera?.stopImageStream();
    }
    _camera?.dispose();
    _faces = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cámara',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _cameraPreview(),
              if (_faces == null)
                Text('Esperando...')
              else if (_faces.isEmpty)
                Text('Detectando...')
              else
                Table(children: [
                  TableRow(
                    children: [
                      Text('Ojo Izq: '),
                      Text(_faces[0].leftEyeOpenProbability.toString()),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text('Ojo Der: '),
                      Text(_faces[0].rightEyeOpenProbability.toString()),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text('Sonrisa: '),
                      Text(_faces[0].smilingProbability.toString()),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text('Euler Y: '),
                      Text(_faces[0].headEulerAngleY.toString()),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text('Euler Z: '),
                      Text(_faces[0].headEulerAngleZ.toString()),
                    ],
                  ),
                ]),
            ]),
      ),
    );
  }

  Widget _cameraPreview() {
    if (_camera != null) {
      return Container(
        child: AspectRatio(
          aspectRatio: _camera.value.aspectRatio,
          child: CameraPreview(
            _camera,
          ),
        ),
      );
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void _initializeCamera() async {
    final CameraDescription description =
        await CameraUtil.getCamera(_direction);

    _camera = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _camera.initialize();
    _camera.startImageStream((CameraImage image) {
      if (_isDetecting) return;

      setState(() {
        _isDetecting = true;
      });

      Uint8List planes = CameraUtil.concatenatePlanes(image.planes);
      FirebaseVisionImageMetadata metadata = CameraUtil.buildMetaData(
        image,
        CameraUtil.rotationIntToImageRotation(
          description.sensorOrientation,
        ),
      );

      CameraUtil.detect(
        planes: planes,
        metadata: metadata,
        detectInImage: _getDetectionMethod(),
      ).then(
        (faces) {
          setState(() {
            if (faces != null) {
              if (faces.isNotEmpty) {
                if (DateTime.now().difference(_lastSent).inSeconds > 3) {
                  SelfieService.sendImage(planes, metadata);
                  _lastSent = DateTime.now();
                }
              }
              setState(() {
                _faces = faces;
              });
            }
          });
        },
      ).whenComplete(() => _isDetecting = false);
    });
  }

  Future<List<Face>> Function(FirebaseVisionImage image) _getDetectionMethod() {
    return _faceDetector.processImage;
  }
}
