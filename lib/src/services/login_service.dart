import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/config.dart';

class LoginService {
  static String _url = Config.serverUrl + 'auth';

  static Future<ApiResponse> login(String username) async {
    try {
      Map<String, String> requestBody = {
        'username': username,
      };

      final response = await http.post(
        _url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
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
