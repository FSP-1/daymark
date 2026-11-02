import 'package:flutter/widgets.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/app.dart';
import 'features/sticky_notes/data/local/app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(DaymarkApp(database: AppDatabase.production()));
}
