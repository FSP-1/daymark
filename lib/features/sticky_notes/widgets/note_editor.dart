import 'package:material_ui/material_ui.dart';

import '../../../core/drawing/drawing_attachment.dart';
import '../../../core/drawing/drawing_stroke.dart';
import '../../../core/localization/app_localizations.dart';
import '../domain/sticky_note.dart';

class NoteEditor extends StatelessWidget {
  const NoteEditor({
    required this.titleController,
    required this.subtitleController,
    required this.controller,
    required this.onSubmit,
    required this.onDrawingChanged,
    required this.format,
    required this.onFormatChanged,
    required this.editing,
    this.initialStrokes = const [],
    super.key,
  });

  final TextEditingController controller;
  final TextEditingController titleController;
  final TextEditingController subtitleController;
  final VoidCallback? onSubmit;
  final ValueChanged<List<DrawingStroke>>? onDrawingChanged;
  final List<DrawingStroke> initialStrokes;
  final NoteFormat format;
  final ValueChanged<NoteFormat>? onFormatChanged;
  final bool editing;

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
            Wrap(
              key: const Key('note-format'),
              spacing: 8,
              children: [
                for (final option in NoteFormat.values)
                  ChoiceChip(
                    label: Text(strings.notes('format_${option.name}')),
                    selected: format == option,
                    onSelected: onFormatChanged == null
                        ? null
                        : (_) => onFormatChanged!(option),
                  ),
              ],
            ),
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
            if (format == NoteFormat.text)
              TextField(
                key: const Key('note-content'),
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: strings.notes('noteLabel'),
                  hintText: strings.notes('noteHint'),
                  border: InputBorder.none,
                ),
              )
            else
              _NoteListEditor(controller: controller, format: format),
            DrawingAttachment(
              key: const Key('note-drawing'),
              strokes: initialStrokes,
              previewHeight: 120,
              onChanged: onDrawingChanged,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                key: const Key('add-note'),
                onPressed: onSubmit,
                icon: Icon(editing ? Icons.check : Icons.add),
                label: Text(strings.notes(editing ? 'saveChanges' : 'addNote')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteListEditor extends StatefulWidget {
  const _NoteListEditor({required this.controller, required this.format});
  final TextEditingController controller;
  final NoteFormat format;

  @override
  State<_NoteListEditor> createState() => _NoteListEditorState();
}

class _NoteListEditorState extends State<_NoteListEditor> {
  late final List<TextEditingController> _rows;

  @override
  void initState() {
    super.initState();
    _rows = [
      for (final text in StickyNote.listItems(widget.controller.text))
        TextEditingController(text: text),
    ];
    if (_rows.isEmpty) _rows.add(TextEditingController());
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _sync() {
    widget.controller.text = StickyNote.listItems(
      _rows.map((row) => row.text).join('\n'),
    ).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final numbered = widget.format == NoteFormat.numbered;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, row) in _rows.indexed)
            Row(
              key: ObjectKey(row),
              children: [
                SizedBox(
                  width: 32,
                  child: numbered
                      ? Text('${index + 1}.')
                      : const Icon(Icons.check_box_outline_blank, size: 20),
                ),
                Expanded(
                  child: TextField(
                    controller: row,
                    decoration: InputDecoration(
                      hintText: strings.notes('itemHint'),
                      isDense: true,
                    ),
                    onChanged: (_) => _sync(),
                  ),
                ),
                IconButton(
                  tooltip: strings.notes('removeItem'),
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() => _rows.removeAt(index));
                    _sync();
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => row.dispose(),
                    );
                  },
                ),
              ],
            ),
          TextButton.icon(
            key: const Key('note-add-item'),
            onPressed: () => setState(() => _rows.add(TextEditingController())),
            icon: const Icon(Icons.add),
            label: Text(strings.notes('addItem')),
          ),
        ],
      ),
    );
  }
}
