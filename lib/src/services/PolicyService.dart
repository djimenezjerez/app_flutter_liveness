import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/config.dart';

class PolicyService {
  static String _url = Config.serverUrl + 'policy';

  static Future<dynamic> getPolicy() async {
    try {
      final response = await http.get(
        Uri.parse(_url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        return apiResponseFromJson(
          utf8.decode(response.bodyBytes),
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse();
    }
  }
}
