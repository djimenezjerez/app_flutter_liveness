import 'dart:io';
import 'dart:typed_data';
import 'package:muserpol_app/src/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';

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
      pensionEntity: prefs.getString('user_pension_entity'),
      category: prefs.getString('user_category'),
      enrolled: prefs.getBool('user_enrolled'),
      verified: prefs.getBool('user_verified'),
    );
  }

  static Future<String> getDir(String path) async {
    final externalDirectory = await getExternalStorageDirectory();
    return externalDirectory.path + '/' + path + '/';
  }

  static void removeDir(String path, {bool recreate = false}) {
    if (Directory(path).existsSync()) {
      Directory(path).deleteSync(
        recursive: true,
      );
      if (recreate) {
        Directory(path).createSync();
      }
    }
  }

  static void createDir(String path) {
    if (!Directory(path).existsSync()) {
      Directory(path).createSync();
    }
  }

  static Future<String> saveFile(
    String path,
    String fileName,
    Uint8List data,
  ) async {
    try {
      path = await getDir(path);
      if (!Directory(path).existsSync()) {
        Directory(path).createSync();
      }
      File file = new File(path + fileName);
      file.writeAsBytesSync(data);
      return path + fileName;
    } catch (e) {
      print(e);
      return '';
    }
  }

  static Future<void> openFile(String link, String fileName) async {
    try {
      http.Client client = new http.Client();
      http.Response response = await client.get(
        Uri.parse(link),
      );
      Uint8List bytes = response.bodyBytes;
      String file = await saveFile('Documents', fileName, bytes);
      OpenFile.open(file);
    } catch (e) {
      print(e);
    }
  }
}
