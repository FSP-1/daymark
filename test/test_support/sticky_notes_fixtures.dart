import 'dart:io';

import 'package:daymark/features/sticky_notes/data/local/app_database.dart';

File createTemporaryStickyNotesDatabaseFile() {
  return File(
    '${Directory.systemTemp.path}${Platform.pathSeparator}'
    'daymark_sticky_notes_${DateTime.now().microsecondsSinceEpoch}.db',
  );
}

AppDatabase openTemporaryStickyNotesDatabase(File file) {
  return AppDatabase.testAt(file);
}
