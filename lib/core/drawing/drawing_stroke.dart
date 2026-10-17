import 'dart:convert';

class DrawingPoint {
  const DrawingPoint(this.x, this.y);

  final double x;
  final double y;

  Map<String, double> toJson() => {'x': x, 'y': y};

  factory DrawingPoint.fromJson(Map<String, dynamic> json) =>
      DrawingPoint(json['x'] as double, json['y'] as double);
}

class DrawingStroke {
  const DrawingStroke(
    this.points, {
    this.isErased = false,
    this.color = 0xff4527a0,
    this.width = 3,
  });

  final List<DrawingPoint> points;
  final bool isErased;
  final int color;
  final double width;

  Map<String, dynamic> toJson() => {
    'points': points.map((point) => point.toJson()).toList(),
    'isErased': isErased,
    'color': color,
    'width': width,
  };

  factory DrawingStroke.fromJson(Map<String, dynamic> json) => DrawingStroke(
    (json['points'] as List<dynamic>)
        .map((point) => DrawingPoint.fromJson(point as Map<String, dynamic>))
        .toList(),
    isErased: json['isErased'] as bool? ?? false,
    color: json['color'] as int? ?? 0xff4527a0,
    width: (json['width'] as num?)?.toDouble() ?? 3,
  );
}

String encodeDrawing(List<DrawingStroke> strokes) =>
    jsonEncode(strokes.map((stroke) => stroke.toJson()).toList());

List<DrawingStroke> decodeDrawing(String? value) {
  if (value == null || value.isEmpty) {
    return const [];
  }
  final decoded = jsonDecode(value) as List<dynamic>;
  return decoded
      .map((stroke) => DrawingStroke.fromJson(stroke as Map<String, dynamic>))
      .toList();
}
