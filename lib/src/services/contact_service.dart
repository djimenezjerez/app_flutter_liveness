import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/contact.dart';
import 'package:muserpol_app/src/services/config.dart';

class ContactService {
  static String _url = Config.serverUrl + 'city';

  static Future<List<Contact>> getContacts() async {
    try {
      final response = await http.get(
        _url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return List<Contact>.from(json
            .decode(utf8.decode(response.bodyBytes))['data']['cities']
            .map((x) => Contact.fromMap(x)));
      } else {
        return List<Contact>.empty();
      }
    } catch (e) {
      return List<Contact>.empty();
    }
  }
}
