import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/drawing/drawing_canvas.dart';
import '../../../core/drawing/drawing_stroke.dart';
import '../../../core/localization/app_localizations.dart';
import '../domain/journal_entry.dart';
import 'journal_view_model.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final model = context.watch<JournalViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text(strings.journal('title'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: Text(strings.journal('newEntry')),
      ),
      body: switch (model.status) {
        JournalStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        JournalStatus.empty => _EmptyJournal(
          onCreate: () => _openEditor(context),
        ),
        JournalStatus.error => Center(
          child: FilledButton.icon(
            onPressed: () => context.read<JournalViewModel>().load(),
            icon: const Icon(Icons.refresh),
            label: Text(strings.journal(model.errorMessage ?? 'loadJournal')),
          ),
        ),
        _ => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            Text(
              strings.journal('subtitle'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            for (var index = 0; index < model.entries.length; index++) ...[
              if (index == 0 ||
                  model.entries[index].entryDate.year !=
                      model.entries[index - 1].entryDate.year ||
                  model.entries[index].entryDate.month !=
                      model.entries[index - 1].entryDate.month)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    MaterialLocalizations.of(context).formatMonthYear(
                      model.entries[index].entryDate,
                    ),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              _EntryCard(entry: model.entries[index]),
            ],
          ],
        ),
      },
    );
  }

  Future<void> _openEditor(
    BuildContext context, [
    JournalEntryModel? entry,
  ]) async {
    final journalViewModel = context.read<JournalViewModel>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: journalViewModel,
          child: _JournalEditorPage(entry: entry),
        ),
      ),
    );
  }
}

class _EmptyJournal extends StatelessWidget {
  const _EmptyJournal({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              strings.journal('empty'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              strings.journal('emptyDescription'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: Text(strings.journal('newEntry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});
  final JournalEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final title = entry.title?.trim().isNotEmpty == true
        ? entry.title!
        : strings.journal('untitled');
    return Card(
      child: InkWell(
        onTap: () {
          final journalViewModel = context.read<JournalViewModel>();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChangeNotifierProvider.value(
                value: journalViewModel,
                child: _JournalReadingPage(entry: entry),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MaterialLocalizations.of(context)
                          .formatMediumDate(entry.entryDate),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      entry.content.trim().isEmpty
                          ? strings.journal('drawingEntry')
                          : entry.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (entry.drawingData?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: DrawingPreview(
                    strokes: decodeDrawing(entry.drawingData),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalEditorPage extends StatefulWidget {
  const _JournalEditorPage({this.entry});
  final JournalEntryModel? entry;
  @override
  State<_JournalEditorPage> createState() => _JournalEditorPageState();
}

class _JournalEditorPageState extends State<_JournalEditorPage> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  late DateTime _date;
  late List<DrawingStroke> _strokes;
  late final String _initialTitle;
  late final String _initialContent;
  late final DateTime _initialDate;
  late final String? _initialDrawingData;
  var _isSaving = false;
  var _allowPop = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _title = TextEditingController(text: entry?.title);
    _content = TextEditingController(text: entry?.content);
    _date = entry?.entryDate ?? DateTime.now();
    _strokes = decodeDrawing(entry?.drawingData);
    _initialTitle = entry?.title ?? '';
    _initialContent = entry?.content ?? '';
    _initialDate = _date;
    _initialDrawingData = entry?.drawingData;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final model = context.watch<JournalViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entry == null
              ? strings.journal('newEntry')
              : strings.journal('edit'),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(strings.journal('save')),
          ),
        ],
      ),
      body: PopScope(
        canPop: _allowPop,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handleBack();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (model.errorMessage != null)
                Text(
                  strings.journal(model.errorMessage!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  '${strings.journal('date')}: '
                  '${MaterialLocalizations.of(context).formatMediumDate(_date)}',
                ),
              ),
              TextField(
                key: const Key('journal-title'),
                controller: _title,
                style: Theme.of(context).textTheme.headlineMedium,
                decoration: InputDecoration(
                  hintText: strings.journal('titleHint'),
                  border: InputBorder.none,
                ),
              ),
              TextField(
                key: const Key('journal-content'),
                controller: _content,
                minLines: 12,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: strings.journal('contentHint'),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),
              DrawingCanvas(
                initialStrokes: _strokes,
                onChanged: (value) => _strokes = value,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final model = context.read<JournalViewModel>();
    final entry = (widget.entry ?? JournalEntryModel.create()).copyWith(
      title: _title.text,
      content: _content.text,
      entryDate: _date,
      drawingData: _strokes.isEmpty ? null : encodeDrawing(_strokes),
      clearDrawing: _strokes.isEmpty,
    );
    final saved = await model.save(entry);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved != null) {
      _allowPop = true;
      Navigator.pop(context, saved);
    }
  }

  bool get _hasUnsavedChanges {
    final drawingData = _strokes.isEmpty ? null : encodeDrawing(_strokes);
    return _title.text != _initialTitle ||
        _content.text != _initialContent ||
        _date != _initialDate ||
        drawingData != _initialDrawingData;
  }

  Future<void> _handleBack() async {
    if (_isSaving) return;
    if (!_hasUnsavedChanges) {
      _allowPop = true;
      if (mounted) Navigator.pop(context);
      return;
    }
    final strings = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.journal('discardTitle')),
        content: Text(strings.journal('discardDescription')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.journal('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.journal('discard')),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      _allowPop = true;
      Navigator.pop(context);
    }
  }
}

class _JournalReadingPage extends StatefulWidget {
  const _JournalReadingPage({required this.entry});
  final JournalEntryModel entry;

  @override
  State<_JournalReadingPage> createState() => _JournalReadingPageState();
}

class _JournalReadingPageState extends State<_JournalReadingPage> {
  late JournalEntryModel _entry = widget.entry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.journal('reading')),
        actions: [
          IconButton(
            onPressed: () => _edit(context),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
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
                  .formatMediumDate(_entry.entryDate),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Text(
              _entry.title?.trim().isNotEmpty == true
                  ? _entry.title!
                  : strings.journal('untitled'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Text(_entry.content, style: Theme.of(context).textTheme.bodyLarge),
            if (_entry.drawingData?.isNotEmpty == true) ...[
              const SizedBox(height: 24),
              DrawingPreview(
                strokes: decodeDrawing(_entry.drawingData),
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
    final journalViewModel = context.read<JournalViewModel>();
    final updated = await Navigator.of(context).push<JournalEntryModel>(
      MaterialPageRoute<JournalEntryModel>(
        builder: (_) => ChangeNotifierProvider.value(
          value: journalViewModel,
          child: _JournalEditorPage(entry: _entry),
        ),
      ),
    );
    if (updated != null && mounted) setState(() => _entry = updated);
  }

  Future<void> _delete(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.journal('delete')),
        content: Text(strings.journal('deleteConfirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.journal('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.journal('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<JournalViewModel>().delete(_entry);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
