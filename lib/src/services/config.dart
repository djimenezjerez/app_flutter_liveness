import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

class Config {
  static String get serverHost => _getStr('BACKEND_HOST');
  static int get serverPort => _getInt('BACKEND_PORT');
  static bool get serverSsl => _getBool('BACKEND_SSL');
  static String get apiVersion => _getStr('API_VERSION');
  static String get apkVersion => _getStr('APK_VERSION');
  static String get serverUrl =>
      (Config.serverSsl ? 'https' : 'http') +
      '://' +
      Config.serverHost +
      ':' +
      Config.serverPort.toString() +
      '/api/' +
      Config.apiVersion.toString() +
      '/';
  static String get appName => _getStr('APP_NAME');
  static Map<String, String> routes = {
    'root': '/',
    'login': '/login',
    'contacts': '/contacts',
    'economic_complements': '/economic_complements',
    'economic_complement_create': '/economic_complement_create',
    'camera_view': '/camera_view',
  };

  static String _getStr(String name) => DotEnv.env[name] ?? '';
  static bool _getBool(String name) => DotEnv.env[name] == null
      ? false
      : DotEnv.env[name].toLowerCase() == 'true';
  static int _getInt(String name) => int.parse(DotEnv.env[name]);
}
