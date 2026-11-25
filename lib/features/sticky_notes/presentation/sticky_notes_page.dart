import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../widgets/note_editor.dart';
import '../../../core/drawing/drawing_canvas.dart';
import '../../../core/drawing/drawing_stroke.dart';
import '../../../core/localization/app_localizations.dart';
import '../domain/sticky_note.dart';
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

  static Future<void> openEditor(BuildContext context, {DateTime? date}) async {
    final viewModel = context.read<StickyNotesViewModel>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: viewModel,
          child: _StickyNoteEditorPage(initialDate: date),
        ),
      ),
    );
  }

  static void openNote(BuildContext context, StickyNote note) {
    final viewModel = context.read<StickyNotesViewModel>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: viewModel,
          child: _StickyNoteReadingPage(note: note),
        ),
      ),
    );
  }
}

class _StickyNotesPageState extends State<StickyNotesPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
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

    return Scaffold(
      appBar: AppBar(title: Text(strings.notes('title'))),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-note-action'),
        heroTag: 'sticky-notes-add',
        onPressed: () => StickyNotesPage.openEditor(context),
        icon: const Icon(Icons.add),
        label: Text(strings.notes('addNote')),
      ),
      body: ListView(
        key: const Key('sticky-notes-scroll'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Text(
            strings.notes('listDescription'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
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
                viewModel.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (viewModel.status == StickyNotesStatus.loading)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.visibleNotes.isEmpty)
            _EmptyNotes(
              filtered: !viewModel.filter.isEmpty,
              onCreate: () => StickyNotesPage.openEditor(context),
            )
          else
            for (final note in viewModel.visibleNotes) _NoteCard(note: note),
        ],
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.filtered, required this.onCreate});

  final bool filtered;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(
            filtered ? Icons.search_off : Icons.lightbulb_outline,
            size: 48,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 10),
          Text(
            filtered ? strings.notes('noMatches') : strings.notes('empty'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            filtered
                ? strings.notes('noMatchesDescription')
                : strings.notes('emptyDescription'),
            textAlign: TextAlign.center,
          ),
          if (!filtered) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: Text(strings.notes('addNote')),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final StickyNote note;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Card(
      color: _noteColors[(note.id ?? 0) % _noteColors.length],
      child: InkWell(
        onTap: () => _openReading(context),
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
                        if (note.title?.trim().isNotEmpty == true) note.content,
                      ].join('\n'),
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
              if (note.drawingData?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Tooltip(
                    message: strings.notes('drawingIncluded'),
                    child: Icon(
                      Icons.draw_outlined,
                      semanticLabel: strings.notes('drawingIncluded'),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openReading(BuildContext context) =>
      StickyNotesPage.openNote(context, note);
}

class _StickyNoteEditorPage extends StatefulWidget {
  const _StickyNoteEditorPage({this.note, this.initialDate});

  final StickyNote? note;
  final DateTime? initialDate;

  @override
  State<_StickyNoteEditorPage> createState() => _StickyNoteEditorPageState();
}

class _StickyNoteEditorPageState extends State<_StickyNoteEditorPage> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _contentController = TextEditingController();
  late List<DrawingStroke> _drawingStrokes;
  var _isSaving = false;
  DateTime? _associatedDate;

  StickyNote? get _note => widget.note;

  @override
  void initState() {
    super.initState();
    _titleController.text = _note?.title ?? '';
    _subtitleController.text = _note?.subtitle ?? '';
    _contentController.text = _note?.content ?? '';
    _drawingStrokes = decodeDrawing(_note?.drawingData);
    _associatedDate = _note?.associatedDate ?? widget.initialDate;
  }

  Future<void> _pickAssociatedDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
      initialDate: _associatedDate ?? DateTime.now(),
    );
    if (date != null && mounted) setState(() => _associatedDate = date);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StickyNotesViewModel>();
    final strings = AppLocalizations.of(context);
    final showError =
        viewModel.errorMessage != null &&
        viewModel.status != StickyNotesStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _note == null ? strings.notes('addNote') : strings.notes('editNote'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (showError)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  viewModel.status == StickyNotesStatus.validationError
                      ? strings.error('emptyNote')
                      : strings.error('saveNote'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(strings.calendar('associatedDate')),
              subtitle: Text(
                _associatedDate == null
                    ? strings.calendar('noDate')
                    : MaterialLocalizations.of(context)
                          .formatFullDate(_associatedDate!),
              ),
              onTap: _isSaving ? null : _pickAssociatedDate,
              trailing: _associatedDate == null
                  ? null
                  : IconButton(
                      tooltip: strings.calendar('removeDate'),
                      onPressed: _isSaving
                          ? null
                          : () => setState(() => _associatedDate = null),
                      icon: const Icon(Icons.clear),
                    ),
            ),
            NoteEditor(
              titleController: _titleController,
              subtitleController: _subtitleController,
              controller: _contentController,
              initialStrokes: _drawingStrokes,
              onDrawingChanged: _isSaving
                  ? null
                  : (strokes) => setState(() => _drawingStrokes = strokes),
              onSubmit: _isSaving
                  ? null
                  : () async {
                      setState(() => _isSaving = true);
                      final model = context.read<StickyNotesViewModel>();
                      final note =
                          _note?.copyWith(
                            content: _contentController.text,
                            title: _titleController.text.trim().isEmpty
                                ? null
                                : _titleController.text,
                            subtitle: _subtitleController.text.trim().isEmpty
                                ? null
                                : _subtitleController.text,
                            drawingData: _drawingStrokes.isEmpty
                                ? null
                                : encodeDrawing(_drawingStrokes),
                            clearTitle: _titleController.text.trim().isEmpty,
                            clearSubtitle: _subtitleController.text
                                .trim()
                                .isEmpty,
                            clearDrawing: _drawingStrokes.isEmpty,
                            associatedDate: _associatedDate,
                            clearAssociatedDate: _associatedDate == null,
                          ) ??
                          StickyNote.create(
                            content: _contentController.text,
                            associatedDate: _associatedDate,
                            title: _titleController.text,
                            subtitle: _subtitleController.text,
                            drawingData: _drawingStrokes.isEmpty
                                ? null
                                : encodeDrawing(_drawingStrokes),
                          );
                      final saved = await model.saveNote(note);
                      if (!context.mounted) return;
                      if (saved == null) {
                        setState(() => _isSaving = false);
                      } else {
                        Navigator.pop(context, saved);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyNoteReadingPage extends StatefulWidget {
  const _StickyNoteReadingPage({required this.note});

  final StickyNote note;

  @override
  State<_StickyNoteReadingPage> createState() => _StickyNoteReadingPageState();
}

class _StickyNoteReadingPageState extends State<_StickyNoteReadingPage> {
  late StickyNote _note = widget.note;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.notes('reading')),
        actions: [
          IconButton(
            tooltip: strings.notes('editNote'),
            onPressed: () => _edit(context),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: strings.notes('deleteNote'),
            onPressed: () => _delete(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MaterialLocalizations.of(context)
                  .formatMediumDate(_note.createdAt),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Text(
              _note.title?.trim().isNotEmpty == true
                  ? _note.title!
                  : strings.notes('untitled'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (_note.subtitle?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                _note.subtitle!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
            const SizedBox(height: 24),
            Text(_note.content, style: Theme.of(context).textTheme.bodyLarge),
            if (_note.drawingData?.isNotEmpty == true) ...[
              const SizedBox(height: 24),
              DrawingPreview(
                strokes: decodeDrawing(_note.drawingData),
                width: double.infinity,
                height: 220,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final viewModel = context.read<StickyNotesViewModel>();
    final updated = await Navigator.of(context).push<StickyNote>(
      MaterialPageRoute<StickyNote>(
        builder: (_) => ChangeNotifierProvider.value(
          value: viewModel,
          child: _StickyNoteEditorPage(note: _note),
        ),
      ),
    );
    if (updated != null && mounted) setState(() => _note = updated);
  }

  Future<void> _delete(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.notes('deleteNote')),
        content: Text(strings.notes('deleteConfirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.journal('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.notes('deleteNote')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted || _note.id == null) return;
    final viewModel = context.read<StickyNotesViewModel>();
    final deleted = await viewModel.deleteNote(_note.id!);
    if (!context.mounted) return;
    if (deleted) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.error('deleteNote'))));
    }
  }
}
