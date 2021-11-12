import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/config.dart';

class ErrorService {
  static String _url = Config.serverUrl + 'device_error';

  static Future<ApiResponse> send(Map requestBody) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
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
