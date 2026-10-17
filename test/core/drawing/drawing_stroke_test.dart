import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/core/drawing/drawing_stroke.dart';

void main() {
  test('round trips strokes without losing points or erase state', () {
    const strokes = [
      DrawingStroke(
        [DrawingPoint(1, 2), DrawingPoint(3, 4)],
        color: 0xff1565c0,
        width: 8,
      ),
      DrawingStroke([DrawingPoint(5, 6)], isErased: true),
    ];

    final restored = decodeDrawing(encodeDrawing(strokes));

    expect(restored.length, 2);
    expect(restored.first.points.last.x, 3);
    expect(restored.first.color, 0xff1565c0);
    expect(restored.first.width, 8);
    expect(restored.last.isErased, isTrue);
  });
}
