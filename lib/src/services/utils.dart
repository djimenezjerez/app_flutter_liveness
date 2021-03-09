import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static Future<String> get token async => _getToken();

  static Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('api_token')) {
      return prefs.getString('api_token');
    } else {
      return '';
    }
  }
}
