import 'package:flutter/material.dart';
import 'package:muserpol_app/src/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await DotEnv().load('.env');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp());
}
