import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:platform_device_id/platform_device_id.dart';

class LoginService {
  static String _url = Config.serverUrl + 'auth';

  static Future<ApiResponse> login(String identityCard) async {
    try {
      String deviceId = await PlatformDeviceId.getDeviceId;
      Map<String, String> requestBody = {
        'identity_card': identityCard,
        'device_id': deviceId
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

  static Future<ApiResponse> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('api_token')) {
        String token = prefs.getString('api_token');

        final response = await http.delete(_url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });
        return apiResponseFromJson(
          utf8.decode(response.bodyBytes),
          response.statusCode,
        );
      } else {
        return ApiResponse();
      }
    } catch (e) {
      return ApiResponse();
    }
  }

  static void setUserData(BuildContext context, Map data) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_token', data['api_token']);
      await prefs.setStringList('user', [
        data['user']['id'].toString(),
        data['user']['full_name'],
        data['user']['degree'],
        data['user']['identity_card'],
        data['user']['enrolled'].toString(),
      ]);
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
      await LoginService.logout();
      for (var item in [
        'api_token',
        'user',
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
      bool loggedIn = true;
      for (var key in [
        'api_token',
        // 'tokenExpiration',
        'user',
      ]) {
        loggedIn &= prefs.containsKey(key);
      }
      // if (loggedIn) {
      //   final now = DateTime.now();
      //   final expiration = DateTime.parse(prefs.getString('tokenExpiration'));
      //   loggedIn &= now.isBefore(expiration);
      // }
      return loggedIn;
    } catch (e) {
      return false;
    }
  }
}
