import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static String get token => _getToken();

  static dynamic _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('api_token')) {
      return prefs.getString('api_token');
    } else {
      return '';
    }
  }
}
