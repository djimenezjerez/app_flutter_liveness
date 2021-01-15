import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/economic_complement.dart';
import 'package:muserpol_app/src/services/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EconomicComplementService {
  static String _url = Config.serverUrl + 'economic_complement';

  static Future<Map<String, dynamic>> getEconomicComplements(
    int page,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('api_token');
      final response = await http.get(
        _url + '?page=' + page.toString(),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        String decodedResponse = utf8.decode(response.bodyBytes);
        Map<String, dynamic> body = json.decode(decodedResponse)['data'];
        return {
          'current_page': int.parse(body['current_page'].toString()),
          'last_page': int.parse(body['last_page'].toString()),
          'total': int.parse(body['total'].toString()),
          'economic_complements': economicComplementsFromJson(decodedResponse),
        };
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }
}
