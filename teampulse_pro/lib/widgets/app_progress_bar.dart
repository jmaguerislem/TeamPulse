import 'package:flutter/material.dart';

import '../core/app_palette.dart';

/// Barre de progression arrondie. La valeur est annoncée en pourcentage.
class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 → 1.0
  final Color color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      value: '${(v * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: LinearProgressIndicator(
          value: v,
          minHeight: height,
          backgroundColor: context.palette.outline,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    );
  }
}
