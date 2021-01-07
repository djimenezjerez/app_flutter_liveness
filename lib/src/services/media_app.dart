import 'package:flutter/material.dart';

class MediaApp {
  bool isPortrait;
  double screenHeight;
  double screenWidth;

  MediaApp(BuildContext context) {
    this.isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    this.screenHeight = MediaQuery.of(context).size.height;
    this.screenWidth = MediaQuery.of(context).size.width;
  }
}
