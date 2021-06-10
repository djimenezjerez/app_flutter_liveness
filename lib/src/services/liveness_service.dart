import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:muserpol_app/src/services/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LivenessService {
  static String _url = Config.serverUrl + 'liveness';

  static Future<ApiResponse> getAffiliateEnabled(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('api_token');
      final int id = prefs.getInt('user_id');
      final response = await http.get(
        Uri.parse(_url + '/' + id.toString()),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        return apiResponseFromJson(
          utf8.decode(response.bodyBytes),
          response.statusCode,
        );
      } else {
        LoginService.unsetUserData(context);
        return ApiResponse();
      }
    } catch (e) {
      return ApiResponse();
    }
  }
}
