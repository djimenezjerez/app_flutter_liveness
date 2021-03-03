import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get serverHost => _getStr('BACKEND_HOST');
  static int get serverPort => _getInt('BACKEND_PORT');
  static bool get serverSsl => _getBool('BACKEND_SSL');
  static String get apiVersion => _getStr('API_VERSION');
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
    'dashboard': '/dashboard',
    'economic_complements': '/economic_complements',
    'selfie': '/selfie',
  };

  static String _getStr(String name) => DotEnv().env[name] ?? '';
  static bool _getBool(String name) => DotEnv().env[name] == null
      ? false
      : DotEnv().env[name].toLowerCase() == 'true';
  static int _getInt(String name) => int.parse(DotEnv().env[name]);

  static String get webSocketHost => _getStr('WEBSOCKET_HOST');
  static int get webSocketPort => _getInt('WEBSOCKET_PORT');
  static bool get webSocketSsl => _getBool('WEBSOCKET_SSL');
  static String get webSocketUrl =>
      (Config.webSocketSsl ? 'https' : 'http') +
      '://' +
      Config.webSocketHost +
      ':' +
      Config.webSocketPort.toString() +
      '/';
}
