import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/services/config.dart';

class ContactService {
  static String _url = Config.serverUrl + 'auth';

  static Future getContacts() async {
    try {
      final response = await http.get(_url);
      debugPrint(json.decode(utf8.decode(response.bodyBytes)));
    } catch (e) {
      debugPrint(e);
    }
  }
}
