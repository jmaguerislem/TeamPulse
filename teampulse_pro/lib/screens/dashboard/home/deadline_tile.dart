import 'package:flutter/material.dart';

import '../../../core/app_text.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_chip.dart';

/// Ligne « échéance proche » : nom du projet, date, badge urgent / bientôt.
class DeadlineTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final VoidCallback onTap;

  const DeadlineTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.title(context, size: 16),
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: AppText.body(context, size: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusChip(label: badge, color: badgeColor),
        ],
      ),
    );
  }
}
