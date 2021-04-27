import 'package:flutter/material.dart';
import 'package:muserpol_app/src/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

void main() async {
  await DotEnv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp());
}
