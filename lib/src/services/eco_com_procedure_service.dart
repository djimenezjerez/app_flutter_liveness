import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EcoComProcedureService {
  static String _url = Config.serverUrl + 'eco_com_procedure';

  static Future<ApiResponse> getEcoComProcedure(int ecoComProcedureId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('api_token');
      final response = await http.get(
        Uri.parse(_url + '/' + ecoComProcedureId.toString()),
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
}
