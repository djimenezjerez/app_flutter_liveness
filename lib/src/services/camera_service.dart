import 'dart:convert';
import 'dart:io';
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CameraService {
  static String _url = Config.serverUrl + 'liveness';

  static Future<ApiResponse> getLivenessActions() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('api_token');
      final response = await http.get(
        _url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $token",
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

  static Future<ApiResponse> sendImage(String base64Image) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('api_token');
      Map<String, String> requestBody = {
        'image': base64Image,
      };
      final response = await http.post(
        _url,
        body: json.encode(requestBody),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
      );

      print(utf8.decode(response.bodyBytes).toString());

      return apiResponseFromJson(
        utf8.decode(response.bodyBytes),
        response.statusCode,
      );
    } catch (e) {
      return ApiResponse();
    }
  }
}
