import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/models/user.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:muserpol_app/src/views/dashboard_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_id/unique_id.dart';

class LoginService {
  static String _url = Config.serverUrl + 'auth';

  static Future<ApiResponse> login(
      String identityCard, String birthDate) async {
    try {
      String deviceId = await UniqueId.getID;
      Map<String, String> requestBody = {
        'identity_card': identityCard,
        'birth_date': birthDate,
        'device_id': deviceId
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

  static Future<ApiResponse> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('api_token')) {
        final token = prefs.getString('api_token');
        final response = await http.delete(
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
      bool enrolled = data['user']['enrolled'];
      await prefs.setString('api_token', data['api_token']);
      await prefs.setInt('user_id', int.parse(data['user']['id'].toString()));
      await prefs.setBool('user_enrolled', enrolled);
      await prefs.setBool('user_verified', data['user']['verified']);
      await prefs.setString('user_degree', data['user']['degree']);
      await prefs.setString('user_full_name', data['user']['full_name']);
      await prefs.setString(
          'user_identity_card', data['user']['identity_card']);
      await prefs.setString(
          'user_pension_entity', data['user']['pension_entity']);
      await prefs.setString('user_category', data['user']['category']);
      if (enrolled) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/dashboard',
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/camera_view',
          (Route<dynamic> route) => false,
        );
      }
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

  static Future<User> getUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      if (prefs.containsKey('api_token')) {
        final token = prefs.getString('api_token');
        final response = await http.get(
          _url,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: "Bearer $token",
          },
        );
        if (response.statusCode == 200) {
          return userFromJson(utf8.decode(response.bodyBytes));
        } else {
          unsetUserData(context);
          return null;
        }
      } else {
        unsetUserData(context);
        return null;
      }
    } catch (e) {
      unsetUserData(context);
      return null;
    }
  }

  static Future<bool> isLoggedIn(BuildContext context) async {
    try {
      User user = await getUser(context);
      if (user != null) {
        setVerified(user.verified);
        bool savedUserEnrolled = await isEnrolled();
        if (user.enrolled && !savedUserEnrolled) {
          await enroll(context);
        } else if (!user.enrolled) {
          unsetUserData(context);
          return false;
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isEnrolled() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('user_enrolled') || false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isVerified() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('user_verified') || false;
    } catch (e) {
      return false;
    }
  }

  static setVerified(bool verified) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_verified', verified);
    } catch (e) {
      print(e);
    }
  }

  static Future<void> enroll(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_enrolled', true);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => DashboardView(
            dialogMessage: 'Reconocimiento facial completado con éxito.',
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      LoginService.unsetUserData(context);
    }
  }
}
