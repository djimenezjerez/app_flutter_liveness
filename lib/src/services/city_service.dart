import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/city.dart';
import 'package:muserpol_app/src/services/config.dart';

class CityService {
  static String _url = Config.serverUrl + 'city';

  static Future<List<City>> getCities() async {
    try {
      final response = await http.get(
        _url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return citiesFromJson(utf8.decode(response.bodyBytes));
      } else {
        return List<City>.empty();
      }
    } catch (e) {
      return List<City>.empty();
    }
  }
}
