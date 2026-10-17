import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/note_editor.dart';
import '../../../core/drawing/drawing_stroke.dart';
import '../../../core/drawing/drawing_canvas.dart';
import '../../../core/localization/app_localizations.dart';
import 'sticky_notes_view_model.dart';

const _noteColors = [
  Color(0xfffff1a8),
  Color(0xffdff0d8),
  Color(0xffffdce5),
  Color(0xffdcecff),
];

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
    final strings = AppLocalizations.of(context);
    final showError =
        viewModel.errorMessage != null &&
        viewModel.status != StickyNotesStatus.loading;
    final errorText = switch (viewModel.status) {
      StickyNotesStatus.validationError => strings.error('emptyNote'),
      StickyNotesStatus.error when viewModel.notes.isEmpty => strings.error(
        'saveNote',
      ),
      StickyNotesStatus.error => strings.error('saveNote'),
      _ => viewModel.errorMessage,
    };

    return Scaffold(
      appBar: AppBar(title: Text(strings.notes('title'))),
      body: ListView(
        key: const Key('sticky-notes-scroll'),
        padding: const EdgeInsets.all(16),
        children: [
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('note-search'),
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: strings.notes('search'),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    context.read<StickyNotesViewModel>().setFilter(text: value);
                  },
                ),
              ),
              IconButton(
                tooltip: strings.notes('dateFilter'),
                icon: const Icon(Icons.date_range),
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (!mounted || !context.mounted || range == null) return;
                  context.read<StickyNotesViewModel>().setFilter(
                    text: _searchController.text,
                    fromDate: range.start,
                    toDate: range.end,
                  );
                },
              ),
              IconButton(
                tooltip: strings.notes('clearFilters'),
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
                errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (viewModel.status == StickyNotesStatus.loading)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.visibleNotes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  Icon(
                    viewModel.filter.isEmpty
                        ? Icons.lightbulb_outline
                        : Icons.search_off,
                    size: 48,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    viewModel.filter.isEmpty
                        ? strings.notes('empty')
                        : strings.notes('noMatches'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.filter.isEmpty
                        ? strings.notes('emptyDescription')
                        : strings.notes('noMatchesDescription'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          if (viewModel.status != StickyNotesStatus.loading &&
              viewModel.visibleNotes.isNotEmpty)
            for (final note in viewModel.visibleNotes)
              Card(
                color: _noteColors[(note.id ?? 0) % _noteColors.length],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title?.trim().isNotEmpty == true
                                  ? note.title!
                                  : note.content,
                              style: const TextStyle(
                                fontFamily: 'cursive',
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              [
                                if (note.subtitle?.trim().isNotEmpty == true)
                                  note.subtitle!,
                                note.title?.trim().isNotEmpty == true
                                    ? note.content
                                    : null,
                                if (note.drawingData?.isNotEmpty == true)
                                  strings.notes('drawingIncluded'),
                              ].whereType<String>().join('\n'),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              MaterialLocalizations.of(context)
                                  .formatMediumDate(note.createdAt),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                      if (note.drawingData?.isNotEmpty == true) ...[
                        const SizedBox(width: 12),
                        DrawingPreview(
                          strokes: decodeDrawing(note.drawingData),
                          width: 92,
                          height: 72,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
