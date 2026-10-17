import 'package:flutter/material.dart';

import '../../../core/drawing/drawing_canvas.dart';
import '../../../core/drawing/drawing_stroke.dart';
import '../../../core/localization/app_localizations.dart';

class NoteEditor extends StatelessWidget {
  const NoteEditor({
    required this.titleController,
    required this.subtitleController,
    required this.controller,
    required this.onSubmit,
    required this.onDrawingChanged,
    this.initialStrokes = const [],
    this.resetVersion = 0,
    super.key,
  });

  final TextEditingController controller;
  final TextEditingController titleController;
  final TextEditingController subtitleController;
  final VoidCallback onSubmit;
  final ValueChanged<List<DrawingStroke>> onDrawingChanged;
  final List<DrawingStroke> initialStrokes;
  final int resetVersion;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Card(
      color: const Color(0xfffff4a8),
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(18),
          bottomRight: Radius.circular(4),
          bottomLeft: Radius.circular(18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('note-title'),
              controller: titleController,
              decoration: InputDecoration(
                labelText: strings.notes('titleLabel'),
              ),
            ),
            TextField(
              key: const Key('note-subtitle'),
              controller: subtitleController,
              decoration: InputDecoration(
                labelText: strings.notes('subtitleLabel'),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('note-content'),
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: strings.notes('noteLabel'),
                hintText: strings.notes('noteHint'),
                border: InputBorder.none,
              ),
            ),
            DrawingCanvas(
              key: const Key('note-drawing'),
              initialStrokes: initialStrokes,
              resetVersion: resetVersion,
              onChanged: onDrawingChanged,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                key: const Key('add-note'),
                onPressed: onSubmit,
                icon: const Icon(Icons.add),
                label: Text(strings.notes('addNote')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
