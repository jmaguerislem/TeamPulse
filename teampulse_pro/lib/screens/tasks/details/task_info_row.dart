import 'package:flutter/material.dart';

import '../../../core/app_text.dart';
import '../../../widgets/app_card.dart';

/// Ligne « libellé → valeur » de l'écran détail d'une tâche.
class TaskInfoRow extends StatelessWidget {
  final String label;
  final Widget value;
  final VoidCallback? onTap;

  const TaskInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.body(context, size: 14)),
          const SizedBox(width: 12),
          Flexible(child: value),
        ],
      ),
    );
  }
}
