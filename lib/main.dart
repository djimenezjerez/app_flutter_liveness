import 'package:flutter/material.dart';
import 'package:muserpol_app/src/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await DotEnv().load('.env');
  initializeDateFormatting('es_BO', null).then((_) => runApp(MainApp()));
}
