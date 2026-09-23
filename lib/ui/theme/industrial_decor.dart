import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_tokens.dart';

/// A panel with a faint diamond crosshatch, like the knurling on a barbell.
/// Reserved for hero surfaces so it stays special.
class KnurlPanel extends StatelessWidget {
  const KnurlPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.borderColor = AppColors.outline,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.md);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          painter: const KnurlPainter(),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class KnurlPainter extends CustomPainter {
  const KnurlPainter({
    this.spacing = 7,
    this.color = const Color(0x0DF2EFE8), // textPrimary at ~5 %
  });

  final double spacing;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8;
    final extent = size.width + size.height;
    for (var d = -size.height; d < extent; d += spacing) {
      canvas
        ..drawLine(Offset(d, 0), Offset(d + size.height, size.height), paint)
        ..drawLine(Offset(d + size.height, 0), Offset(d, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(KnurlPainter oldDelegate) =>
      oldDelegate.spacing != spacing || oldDelegate.color != color;
}

/// Diagonal safety-yellow/black band, as on gym floor markings.
class HazardStripe extends StatelessWidget {
  const HazardStripe({super.key, this.height = 6});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: const CustomPaint(painter: _HazardPainter()),
      ),
    );
  }
}

class _HazardPainter extends CustomPainter {
  const _HazardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.onAccent);
    final stripe = Paint()..color = AppColors.accent;
    final step = size.height * 2;
    for (var x = -size.height; x < size.width; x += step) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + size.height, 0)
        ..lineTo(x + size.height * 2, 0)
        ..lineTo(x + size.height, size.height)
        ..close();
      canvas.drawPath(path, stripe);
    }
  }

  @override
  bool shouldRepaint(_HazardPainter oldDelegate) => false;
}
