import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/note_editor.dart';
import '../../../core/drawing/drawing_stroke.dart';
import '../../../core/drawing/drawing_canvas.dart';
import 'sticky_notes_view_model.dart';

class StickyNotesPage extends StatefulWidget {
  const StickyNotesPage({super.key});

  @override
  State<StickyNotesPage> createState() => _StickyNotesPageState();
}

class _StickyNotesPageState extends State<StickyNotesPage> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _contentController = TextEditingController();
  final _searchController = TextEditingController();
  List<DrawingStroke> _drawingStrokes = const [];
  int _drawingResetVersion = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StickyNotesViewModel>();
    final showError =
        viewModel.errorMessage != null &&
        viewModel.status != StickyNotesStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Sticky Notes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('note-search'),
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search notes',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    context.read<StickyNotesViewModel>().setFilter(text: value);
                  },
                ),
              ),
              IconButton(
                tooltip: 'Filter by date',
                icon: const Icon(Icons.date_range),
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (!mounted || !context.mounted || range == null) {
                    return;
                  }
                  final currentText = _searchController.text;
                  context.read<StickyNotesViewModel>().setFilter(
                    text: currentText,
                    fromDate: range.start,
                    toDate: range.end,
                  );
                },
              ),
              IconButton(
                tooltip: 'Clear filters',
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<StickyNotesViewModel>().clearFilter();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (showError)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                viewModel.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (viewModel.status == StickyNotesStatus.loading)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.visibleNotes.isEmpty)
            Center(
              child: Text(
                viewModel.filter.isEmpty
                    ? 'No notes yet.'
                    : 'No matching notes.',
              ),
            ),
          const SizedBox(height: 12),
          NoteEditor(
            titleController: _titleController,
            subtitleController: _subtitleController,
            controller: _contentController,
            onDrawingChanged: (strokes) => _drawingStrokes = strokes,
            resetVersion: _drawingResetVersion,
            onSubmit: () async {
              final viewModel = context.read<StickyNotesViewModel>();
              await viewModel.createNote(
                _contentController.text,
                title: _titleController.text,
                subtitle: _subtitleController.text,
                drawingData: encodeDrawing(_drawingStrokes),
              );
              if (!mounted) {
                return;
              }
              if (viewModel.status == StickyNotesStatus.ready) {
                _titleController.clear();
                _subtitleController.clear();
                _contentController.clear();
                setState(() {
                  _drawingStrokes = const [];
                  _drawingResetVersion++;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          if (viewModel.status != StickyNotesStatus.loading &&
              viewModel.visibleNotes.isNotEmpty)
            for (final note in viewModel.visibleNotes)
              Card(
                color: const Color(0xfffff4a8),
                elevation: 2,
                child: ListTile(
                  leading: note.drawingData?.isNotEmpty == true
                      ? DrawingPreview(strokes: decodeDrawing(note.drawingData))
                      : null,
                  title: Text(
                    note.title?.trim().isNotEmpty == true
                        ? note.title!
                        : note.content,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    [
                      if (note.subtitle?.trim().isNotEmpty == true)
                        note.subtitle!,
                      note.title?.trim().isNotEmpty == true
                          ? note.content
                          : null,
                      if (note.drawingData?.isNotEmpty == true)
                        'Drawing included',
                      MaterialLocalizations.of(context)
                          .formatMediumDate(note.createdAt),
                    ].whereType<String>().join('\n'),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
