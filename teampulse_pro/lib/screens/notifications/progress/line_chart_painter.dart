import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_state.dart';

/// Courbes « terminées / en cours / en retard » sur la période choisie.
/// Dessinées à la main (CustomPaint) : aucune dépendance de graphiques.
class LineChartPainter extends CustomPainter {
  final List<DayStat> data;
  final Color gridColor;
  LineChartPainter(this.data, {required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    var maxV = 1;
    for (final d in data) {
      for (final v in [d.done, d.inProgress, d.overdue]) {
        if (v > maxV) maxV = v;
      }
    }

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    Offset point(int i, int value) {
      final x = data.length == 1 ? 0.0 : size.width * i / (data.length - 1);
      final y = size.height - (value / maxV) * (size.height - 12) - 6;
      return Offset(x, y);
    }

    void drawLine(int Function(DayStat) pick, Color color) {
      final path = Path();
      for (var i = 0; i < data.length; i++) {
        final o = point(i, pick(data[i]));
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      // Point final : repère la valeur d'aujourd'hui.
      if (data.isNotEmpty) {
        canvas.drawCircle(
          point(data.length - 1, pick(data.last)),
          5,
          Paint()..color = color,
        );
      }
    }

    drawLine((d) => d.done, AppColors.mint);
    drawLine((d) => d.inProgress, AppColors.primary);
    drawLine((d) => d.overdue, AppColors.coral);
  }

  @override
  bool shouldRepaint(covariant LineChartPainter old) =>
      old.data != data || old.gridColor != gridColor;
}
