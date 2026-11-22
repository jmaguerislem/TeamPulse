import 'package:flutter/material.dart';

import '../../../core/app_text.dart';
import '../../../widgets/app_card.dart';

/// Petite carte de statistique (valeur en grand + libellé).
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
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
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 10),
              Text(value, style: AppText.number(context, size: 28)),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(context, size: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
