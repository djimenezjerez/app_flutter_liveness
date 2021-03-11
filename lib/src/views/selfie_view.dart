import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:convert';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:muserpol_app/src/services/media_app.dart';
import 'package:muserpol_app/src/services/utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wakelock/wakelock.dart';

class SelfieView extends StatefulWidget {
  final bool enroll;
  SelfieView({
    Key key,
    @required this.enroll,
  }) : super(key: key);

  @override
  _SelfieViewState createState() => _SelfieViewState();
}

class _SelfieViewState extends State<SelfieView> {
  Size _size = Size(640, 480);
  File _lastImage;
  final sizes = [
    Size(640, 480),
    Size(720, 480),
    Size(800, 600),
    Size(1280, 720),
  ];
  bool _busy;
  DateTime _lastSent;
  IO.Socket _socket;
  bool _wsConnected;
  String _message;

  @override
  void initState() {
    Wakelock.enable();
    _message = 'Siga las instrucciones, para comenzar presione el botón azul';
    _wsConnected = false;
    _lastSent = DateTime.now();
    wsConnect();
    _busy = false;
    super.initState();
  }

  @override
  void dispose() {
    _wsConnected = false;
    _busy = false;
    _socket.disconnect();
    _socket.dispose();
    Wakelock.disable();
    setState(() {});
    Navigator.pop(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _media = MediaApp(context);
    _size = Size(_media.screenHeight, _media.screenWidth);
    final _imageWidth = 0.85;
    final _imageHeight = 0.65;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cámara',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: _media.screenHeight * 0.09,
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
            if (_lastImage == null)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: _media.screenHeight * 0.02,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: _media.screenWidth / (2 / (1 - _imageWidth)),
                    ),
                    SizedBox(
                      width: _media.screenWidth * _imageWidth,
                      height: _media.screenHeight * _imageHeight,
                      child: Center(
                        child: CameraAwesome(
                          brightness: ValueNotifier<double>(1),
                          testMode: false,
                          enableAudio: ValueNotifier<bool>(false),
                          captureMode: ValueNotifier(CaptureModes.PHOTO),
                          selectDefaultSize: (availableSizes) {
                            for (Size size in sizes) {
                              if (availableSizes.contains(size)) return size;
                            }
                            return availableSizes.first;
                          },
                          sensor: ValueNotifier(Sensors.FRONT),
                          photoSize: ValueNotifier<Size>(_size),
                          switchFlashMode: ValueNotifier(CameraFlashes.NONE),
                          orientation: DeviceOrientation.portraitUp,
                          zoom: ValueNotifier<double>(0),
                          fitted: false,
                          imagesStreamBuilder: (imageStream) {
                            imageStream.listen((Uint8List imageData) {
                              if (imageData != null &&
                                  !_busy &&
                                  _wsConnected &&
                                  _socket != null) {
                                sendImage(imageData);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: EdgeInsets.only(
                  top: _media.screenHeight * 0.02,
                ),
                child: SizedBox(
                  width: _media.screenWidth * _imageWidth,
                  height: _media.screenHeight * _imageHeight,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(
                      math.pi,
                    ),
                    child: Image.file(
                      _lastImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: _media.screenWidth * 0.9,
              child: ElevatedButton(
                onPressed: () => _startEnroll(),
                child: Text(
                  'Iniciar',
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
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startEnroll() {
    _socket.connect();
    setState(() {
      _message = 'Conectado a WS';
    });
  }

  void sendImage(Uint8List imageData) async {
    try {
      if (DateTime.now().difference(_lastSent).inSeconds > 0.5) {
        _busy = true;
        print('Imagen enviada');
        String imageString = base64.encode(imageData);
        _socket.emit(
          'enroll',
          imageString,
        );
        _lastSent = DateTime.now();
        _busy = false;
      }
    } catch (e) {
      _busy = false;
    }
  }

  void wsConnect() async {
    print('Connecting WS');
    _socket = IO.io(Config.webSocketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {
        'token': await Utils.token,
      }
    });
    _socket.onConnecting((_) {
      print('Connecting...');
    });
    _socket.onReconnecting((_) {
      print('Reconnecting...');
    });
    _socket.onConnect((_) {
      _wsConnected = true;
      print('Connected');
      _socket.onDisconnect(
        (_) {
          _wsConnected = false;
          print('Disconnected');
        },
      );
    });
  }
}
