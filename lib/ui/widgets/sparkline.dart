import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tiny trend line of [values] in chronological order. Draws nothing for
/// fewer than two points; a flat series is drawn along the middle.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    this.width = 72,
    this.height = 24,
    this.color = AppColors.accent,
  });

  final List<double> values;
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return SizedBox(width: width, height: height);
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(width, height),
        painter: SparklinePainter(values: values, color: color),
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  const SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  /// Points in local coordinates, leaving room for the end dot.
  List<Offset> pointsFor(Size size) {
    const inset = 3.0;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    final w = size.width - inset * 2;
    final h = size.height - inset * 2;
    return [
      for (var i = 0; i < values.length; i++)
        Offset(
          inset + w * i / (values.length - 1),
          inset + (range == 0 ? h / 2 : h * (1 - (values[i] - min) / range)),
        ),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final points = pointsFor(size);
    final line = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawPath(Path()..addPolygon(points, false), line)
      ..drawCircle(points.last, 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(SparklinePainter oldDelegate) =>
      oldDelegate.color != color || !_listEquals(oldDelegate.values, values);

  static bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
