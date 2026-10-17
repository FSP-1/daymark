import 'package:flutter/material.dart';

import 'drawing_stroke.dart';
import '../localization/app_localizations.dart';

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({
    required this.onChanged,
    this.initialStrokes = const [],
    this.resetVersion = 0,
    super.key,
  });

  final List<DrawingStroke> initialStrokes;
  final ValueChanged<List<DrawingStroke>> onChanged;
  final int resetVersion;

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class DrawingPreview extends StatelessWidget {
  const DrawingPreview({
    required this.strokes,
    this.width = 64,
    this.height = 48,
    super.key,
  });

  final List<DrawingStroke> strokes;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0x66ffffff)),
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(painter: _DrawingPainter(strokes)),
        ),
      ),
    );
  }
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  late List<DrawingStroke> _strokes;
  bool _eraseMode = false;
  bool _expanded = false;
  double _brushWidth = 3;
  int _brushColor = 0xff4527a0;

  @override
  void initState() {
    super.initState();
    _strokes = [...widget.initialStrokes];
  }

  @override
  void didUpdateWidget(covariant DrawingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetVersion != widget.resetVersion) {
      setState(() => _strokes = []);
    }
  }

  DrawingPoint _normalizedPoint(Offset point, Size size) => DrawingPoint(
    (point.dx / size.width).clamp(0.0, 1.0),
    (point.dy / size.height).clamp(0.0, 1.0),
  );

  void _startStroke(Offset point, Size size) {
    setState(() {
      _strokes = [
        ..._strokes,
        DrawingStroke(
          [_normalizedPoint(point, size)],
          isErased: _eraseMode,
          color: _brushColor,
          width: _brushWidth,
          normalized: true,
        ),
      ];
    });
    widget.onChanged(_strokes);
  }

  void _extendStroke(Offset point, Size size) {
    if (_strokes.isEmpty) return;
    final current = _strokes.last;
    setState(() {
      _strokes = [
        ..._strokes.take(_strokes.length - 1),
        DrawingStroke(
          [...current.points, _normalizedPoint(point, size)],
          isErased: current.isErased,
          color: current.color,
          width: current.width,
          normalized: current.normalized,
        ),
      ];
    });
    widget.onChanged(_strokes);
  }

  void _clear() {
    setState(() => _strokes = []);
    widget.onChanged(_strokes);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              strings.notes('drawingOptional'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            IconButton(
              tooltip: _eraseMode
                  ? strings.notes('usePen')
                  : strings.notes('erase'),
              icon: Icon(_eraseMode ? Icons.edit : Icons.auto_fix_high),
              onPressed: () => setState(() => _eraseMode = !_eraseMode),
            ),
            IconButton(
              tooltip: _expanded
                  ? 'Reduce drawing area'
                  : 'Expand drawing area',
              icon: Icon(_expanded ? Icons.fullscreen_exit : Icons.fullscreen),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
            IconButton(
              tooltip: strings.notes('clearDrawing'),
              icon: const Icon(Icons.delete_outline),
              onPressed: _clear,
            ),
          ],
        ),
        Row(
          children: [
            Text(strings.notes('size')),
            Expanded(
              child: Slider(
                key: const Key('brush-size'),
                min: 1,
                max: 16,
                value: _brushWidth,
                onChanged: (value) => setState(() => _brushWidth = value),
              ),
            ),
            for (final color in const [
              0xff4527a0,
              0xff1565c0,
              0xff2e7d32,
              0xffd84315,
              0xff212121,
            ])
              GestureDetector(
                key: Key('brush-color-$color'),
                onTap: () => setState(() => _brushColor = color),
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    color: Color(color),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _brushColor == color
                          ? Colors.white
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(
          height: _expanded ? 300 : 56,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (details) =>
                        _startStroke(details.localPosition, size),
                    onPanUpdate: (details) =>
                        _extendStroke(details.localPosition, size),
                    child: CustomPaint(
                      painter: _DrawingPainter(_strokes),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DrawingPainter extends CustomPainter {
  const _DrawingPainter(this.strokes);

  final List<DrawingStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.isErased ? Colors.white : Color(stroke.color)
        ..strokeWidth = stroke.isErased ? stroke.width * 4 : stroke.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path();
      for (var index = 0; index < stroke.points.length; index++) {
        final point = stroke.points[index];
        final x = (stroke.normalized ? point.x * size.width : point.x).clamp(
          0.0,
          size.width,
        );
        final y = (stroke.normalized ? point.y * size.height : point.y).clamp(
          0.0,
          size.height,
        );
        if (index == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}
