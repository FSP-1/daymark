import 'package:material_ui/material_ui.dart';

import '../localization/app_localizations.dart';
import 'drawing_canvas.dart';
import 'drawing_editor_dialog.dart';
import 'drawing_stroke.dart';

class DrawingAttachment extends StatelessWidget {
  const DrawingAttachment({
    required this.strokes,
    required this.onChanged,
    this.previewHeight = 180,
    super.key,
  });

  final List<DrawingStroke> strokes;
  final ValueChanged<List<DrawingStroke>>? onChanged;
  final double previewHeight;

  Future<void> _openEditor(BuildContext context) async {
    final result = await showDialog<List<DrawingStroke>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DrawingEditorDialog(initialStrokes: strokes),
    );
    if (result != null && context.mounted) onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final hasDrawing = strokes.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasDrawing) ...[
          DrawingPreview(
            strokes: strokes,
            width: double.infinity,
            height: previewHeight,
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: onChanged == null ? null : () => _openEditor(context),
          icon: Icon(hasDrawing ? Icons.edit_outlined : Icons.draw_outlined),
          label: Text(
            strings.drawing(hasDrawing ? 'editDrawing' : 'createDrawing'),
          ),
        ),
      ],
    );
  }
}
