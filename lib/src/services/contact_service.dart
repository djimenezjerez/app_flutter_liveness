import 'package:http/http.dart' as http;
import 'package:muserpol_app/src/models/contact.dart';

class ContactService {
  static const String _url = 'http://192.168.100.10:8001/contacts';

  static Future<List<Contact>> getContacts() async {
    try {
      final response = await http.get(_url);
      if (response.statusCode == 200) {
        final List<Contact> contacts = contactsFromJson(response.body);
        return contacts;
      } else {
        return List<Contact>.empty();
      }
    } catch (e) {
      return List<Contact>.empty();
    }
  }
}
