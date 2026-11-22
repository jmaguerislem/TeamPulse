import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

/// Logo « pulsation » : une ligne de battement de cœur en menthe.
/// Purement décoratif (exclu de l'accessibilité par l'écran qui l'utilise).
class PulseLogo extends StatelessWidget {
  final double width;
  const PulseLogo({super.key, this.width = 120});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * 0.56),
      painter: _PulsePainter(),
    );
  }
}

class _PulsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, h * 0.62)
      ..lineTo(w * 0.22, h * 0.62)
      ..lineTo(w * 0.32, h * 0.14)
      ..lineTo(w * 0.48, h * 0.92)
      ..lineTo(w * 0.6, h * 0.4)
      ..lineTo(w * 0.68, h * 0.62)
      ..lineTo(w, h * 0.62);

    final glow = Paint()
      ..color = AppColors.mint.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final line = Paint()
      ..color = AppColors.mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, glow);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
