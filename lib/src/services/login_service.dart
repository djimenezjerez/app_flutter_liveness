import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:platform_device_id/platform_device_id.dart';

class LoginService {
  static String _url = Config.serverUrl + 'auth';

  static Future<ApiResponse> login(String username) async {
    try {
      String deviceId = await PlatformDeviceId.getDeviceId;
      Map<String, String> requestBody = {
        'username': username,
        'deviceId': deviceId
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
      await prefs.setString('tokenExpiration', data['tokenExpiration']);
      await prefs.setStringList('user', [
        data['user']['id'].toString(),
        data['user']['fullName'],
        data['user']['rank'],
        data['user']['ci'],
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
      bool loggedIn = true;
      for (var key in [
        'token',
        'tokenType',
        'tokenExpiration',
        'user',
      ]) {
        loggedIn &= prefs.containsKey(key);
      }
      if (loggedIn) {
        final now = DateTime.now();
        final expiration = DateTime.parse(prefs.getString('tokenExpiration'));
        loggedIn &= now.isBefore(expiration);
      }
      return loggedIn;
    } catch (e) {
      return false;
    }
  }
}
