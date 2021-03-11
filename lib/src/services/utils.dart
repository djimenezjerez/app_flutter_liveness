import 'package:muserpol_app/src/models/user.dart';
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

  static Future<User> get user async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return User(
      id: prefs.getInt('user_id'),
      fullName: prefs.getString('user_full_name'),
      degree: prefs.getString('user_degree'),
      identityCard: prefs.getString('user_identity_card'),
      enrolled: prefs.getBool('user_enrolled'),
    );
  }
}
