import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/config.dart';

class SelfieService {
  static String _url = Config.serverUrl + 'selfie';

  static Future<ApiResponse> sendImage(
      Uint8List planes, FirebaseVisionImageMetadata metadata) async {
    try {
      Map<String, dynamic> requestBody = {
        'image': {
          'raw': planes,
          'metadata': {
            'width': metadata.size.width,
            'height': metadata.size.height,
            'rotation': metadata.rotation.index,
          },
        },
      };

      final response = await http.post(
        _url,
        body: json.encode(requestBody),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      return apiResponseFromJson(
        utf8.decode(response.bodyBytes),
        response.statusCode,
      );
    } catch (e) {
      return ApiResponse();
    }
  }
}
