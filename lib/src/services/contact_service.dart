import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/contact.dart';
import 'package:muserpol_app/src/services/config.dart';

class ContactService {
  static String _url = Config.serverUrl + 'contacts';

  static Future<List<Contact>> getContacts() async {
    try {
      final response = await http.get(_url);
      if (response.statusCode == 200) {
        final List<Contact> contacts =
            contactsFromJson(utf8.decode(response.bodyBytes));
        return contacts;
      } else {
        return List<Contact>.empty();
      }
    } catch (e) {
      return List<Contact>.empty();
    }
  }
}
