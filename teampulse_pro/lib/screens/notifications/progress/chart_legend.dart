import 'package:flutter/material.dart';

import '../../../core/app_text.dart';

/// Pastille de légende du graphique (couleur + libellé).
class ChartLegend extends StatelessWidget {
  final String label;
  final Color color;
  const ChartLegend({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppText.body(context, size: 13)),
      ],
    );
  }
}
