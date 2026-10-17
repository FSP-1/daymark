import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'features/sticky_notes/data/local/app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DaymarkApp(database: AppDatabase.production()));
}
