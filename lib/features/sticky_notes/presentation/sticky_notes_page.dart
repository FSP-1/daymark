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
  const StickyNotesPage({this.showAppBar = true, super.key});

  final bool showAppBar;

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
      appBar: widget.showAppBar
          ? AppBar(title: Text(strings.notes('title')))
          : null,
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
    final isList = note.format != NoteFormat.text;
    final title = note.title?.trim();
    final subtitle = note.subtitle?.trim();
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
                      title?.isNotEmpty == true
                          ? title!
                          : isList
                          ? strings.notes('format_${note.format.name}')
                          : note.content,
                      maxLines: isList ? 2 : null,
                      overflow: isList ? TextOverflow.ellipsis : null,
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (subtitle?.isNotEmpty == true)
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (isList)
                      _ListPreview(note: note)
                    else if (title?.isNotEmpty == true)
                      Text(
                        note.content,
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

class _ListPreview extends StatelessWidget {
  const _ListPreview({required this.note});
  final StickyNote note;
  static const _previewLimit = 3;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.bodyMedium;
    final localizations = MaterialLocalizations.of(context);
    final items = note.items;
    final checklist = note.format == NoteFormat.checklist;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, item) in items.take(_previewLimit).indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: checklist
                      ? Icon(
                          note.checkedItems.contains(index)
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank,
                          size: 16,
                        )
                      : Text(
                          '${localizations.formatDecimal(index + 1)}.',
                          style: style,
                        ),
                ),
                Expanded(
                  child: Text(
                    item,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _itemStyle(
                      style,
                      checklist && note.checkedItems.contains(index),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (items.length > _previewLimit)
          Text(
            strings
                .notes('moreItems')
                .replaceFirst(
                  '{count}',
                  localizations.formatDecimal(items.length - _previewLimit),
                ),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        if (checklist)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _checklistProgress(context, note, items.length),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
      ],
    );
  }
}

TextStyle _itemStyle(TextStyle? base, bool checked) =>
    (base ?? const TextStyle()).copyWith(
      decoration: checked ? TextDecoration.lineThrough : TextDecoration.none,
    );

String _checklistProgress(BuildContext context, StickyNote note, int total) {
  final dates = MaterialLocalizations.of(context);
  final count = note.checkedItems
      .where((index) => index >= 0 && index < total)
      .length;
  return AppLocalizations.of(context)
      .notes('checklistProgress')
      .replaceFirst('{checked}', dates.formatDecimal(count))
      .replaceFirst('{total}', dates.formatDecimal(total));
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
  late NoteFormat _format;
  DateTime? _associatedDate;

  StickyNote? get _note => widget.note;

  @override
  void initState() {
    super.initState();
    _titleController.text = _note?.title ?? '';
    _subtitleController.text = _note?.subtitle ?? '';
    _contentController.text = _note?.content ?? '';
    _format = _note?.format ?? NoteFormat.text;
    _drawingStrokes = decodeDrawing(_note?.drawingData);
    _associatedDate = _note == null
        ? widget.initialDate ?? DateUtils.dateOnly(DateTime.now())
        : _note!.associatedDate;
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
              editing: _note != null,
              titleController: _titleController,
              subtitleController: _subtitleController,
              controller: _contentController,
              format: _format,
              onFormatChanged: _isSaving
                  ? null
                  : (format) => setState(() => _format = format),
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
                            format: _format,
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
                            format: _format,
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
  bool _savingCheck = false;

  Future<void> _toggleItem(int index, bool value) async {
    final model = context.read<StickyNotesViewModel>();
    final strings = AppLocalizations.of(context);
    final checked = {..._note.checkedItems};
    if (value) {
      checked.add(index);
    } else {
      checked.remove(index);
    }
    setState(() => _savingCheck = true);
    final saved = await model.saveNote(_note.copyWith(checkedItems: checked));
    if (!mounted) return;
    setState(() {
      _savingCheck = false;
      if (saved != null) _note = saved;
    });
    if (saved == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.error('saveNote'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.notes('reading')),
        actions: [
          IconButton(
            tooltip: strings.notes('editNote'),
            onPressed: _savingCheck ? null : () => _edit(context),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: strings.notes('deleteNote'),
            onPressed: _savingCheck ? null : () => _delete(context),
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
                  : strings.notes(
                      _note.format == NoteFormat.text
                          ? 'untitled'
                          : 'format_${_note.format.name}',
                    ),
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
            if (_note.format == NoteFormat.text)
              Text(_note.content, style: Theme.of(context).textTheme.bodyLarge)
            else ...[
              if (_note.format == NoteFormat.checklist)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _checklistProgress(context, _note, _note.items.length),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      for (final (index, item) in _note.items.indexed) ...[
                        if (index > 0) const Divider(height: 1),
                        if (_note.format == NoteFormat.checklist)
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              item,
                              style: _itemStyle(
                                Theme.of(context).textTheme.bodyLarge,
                                _note.checkedItems.contains(index),
                              ),
                            ),
                            value: _note.checkedItems.contains(index),
                            onChanged: _savingCheck
                                ? null
                                : (value) => _toggleItem(index, value ?? false),
                          )
                        else
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Text(
                              '${MaterialLocalizations.of(context).formatDecimal(index + 1)}.',
                            ),
                            title: Text(item),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
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
