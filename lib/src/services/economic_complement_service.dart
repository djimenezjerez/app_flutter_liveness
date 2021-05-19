import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/api_response.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EconomicComplementService {
  static String _url = Config.serverUrl + 'economic_complement';

  static Future<ApiResponse> getEconomicComplements(
    int page,
    bool current,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('api_token');
      final response = await http.get(
        Uri.parse(_url +
            '?page=' +
            page.toString() +
            '&current=' +
            current.toString()),
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

  static Future<dynamic> storeEconomicComplement(
      List<Map<String, String>> attachments,
      int phone,
      int ecoComProcedureId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('api_token');
      final response = await http.post(
        Uri.parse(_url),
        body: json.encode({
          'eco_com_procedure_id': ecoComProcedureId,
          'cell_phone_number': phone,
          'attachments': attachments,
        }),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $token",
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

  static Future<dynamic> printRequestEconomicComplement(int id) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('api_token');
      final response = await http.get(
        Uri.parse(_url + '/print/' + id.toString()),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $token",
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
