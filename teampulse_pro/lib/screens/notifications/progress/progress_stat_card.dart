import 'package:flutter/material.dart';

import '../../../core/app_palette.dart';
import '../../../core/app_text.dart';
import '../../../widgets/app_card.dart';

/// Carte « libellé + gros chiffre » de l'écran Statistiques.
class ProgressStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const ProgressStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        container: true,
        label: '$label : $value',
        excludeSemantics: true,
        child: AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.body(context, size: 14)),
              const SizedBox(height: 6),
              Text(
                value,
                style: AppText.number(
                  context,
                  size: 34,
                  color: context.palette.inkFor(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
