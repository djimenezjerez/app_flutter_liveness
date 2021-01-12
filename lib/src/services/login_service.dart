import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/models/user.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:muserpol_app/src/services/jwt_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static void setUserData(BuildContext context, Map data) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('tokenType', data['tokenType']);
      User user = JwtService.parseJwtPayLoad(data['token']);
      await prefs.setString('name', user.name);
      await prefs.setString('rank', user.rank);
      await prefs.setString('ci', user.ci);
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/dashboard',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      throw Exception('User data was not saved');
    }
  }

  static void unsetUserData(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      for (var item in [
        'token',
        'tokenType',
        'name',
        'rank',
        'ci',
      ]) {
        await prefs.remove(item);
      }
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      throw Exception('User data was not removed');
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('token');
    } catch (e) {
      return false;
    }
  }
}
