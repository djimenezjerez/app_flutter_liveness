import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/eco_com_state.dart';
import 'package:muserpol_app/src/services/config.dart';

class EcoComStateService {
  static String _url = Config.serverUrl + 'eco_com_state';

  static Future<List<EcoComState>> getEcoComStates() async {
    try {
      final response = await http.get(
        _url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return ecoComStatesFromJson(utf8.decode(response.bodyBytes));
      } else {
        return List<EcoComState>.empty();
      }
    } catch (e) {
      return List<EcoComState>.empty();
    }
  }
}
