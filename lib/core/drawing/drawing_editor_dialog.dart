import 'package:material_ui/material_ui.dart';

import '../localization/app_localizations.dart';
import 'drawing_canvas.dart';
import 'drawing_stroke.dart';

class DrawingEditorDialog extends StatefulWidget {
  const DrawingEditorDialog({required this.initialStrokes, super.key});

  final List<DrawingStroke> initialStrokes;

  @override
  State<DrawingEditorDialog> createState() => _DrawingEditorDialogState();
}

class _DrawingEditorDialogState extends State<DrawingEditorDialog> {
  late List<DrawingStroke> _strokes = widget.initialStrokes;

  Future<void> _deleteDrawing() async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.drawing('deleteDrawing')),
        content: Text(strings.drawing('deleteDrawingConfirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.drawing('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.drawing('confirmDeleteDrawing')),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.pop(context, const <DrawingStroke>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(maxWidth: 600),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.drawing('drawingEditorTitle'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Flexible(
              child: DrawingCanvas(
                initialStrokes: widget.initialStrokes,
                initialExpanded: true,
                fitAvailableHeight: true,
                onChanged: (strokes) => _strokes = strokes,
              ),
            ),
            const SizedBox(height: 8),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                if (widget.initialStrokes.isNotEmpty)
                  TextButton(
                    onPressed: _deleteDrawing,
                    child: Text(strings.drawing('deleteDrawing')),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(strings.drawing('cancel')),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    List<DrawingStroke>.unmodifiable(_strokes),
                  ),
                  child: Text(strings.drawing('saveDrawing')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
