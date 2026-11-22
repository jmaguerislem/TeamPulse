import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_palette.dart';
import '../../../core/app_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/icon_tile.dart';

/// Alerte de retard : le point fort de TeamPulse Pro.
/// Rouge corail + icône « ! » quand il y a du retard, verte sinon.
class LateAlertCard extends StatelessWidget {
  final int lateCount;
  final VoidCallback onTap;
  const LateAlertCard({super.key, required this.lateCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final hasLate = lateCount > 0;
    final color = hasLate ? AppColors.coral : AppColors.mint;

    return AppCard(
      onTap: onTap,
      color: color.withValues(alpha: p.isDark ? 0.14 : 0.1),
      borderColor: color.withValues(alpha: 0.45),
      child: Row(
        children: [
          IconTile(
            icon: hasLate
                ? Icons.priority_high_rounded
                : Icons.check_circle_outline_rounded,
            color: color,
            size: 48,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasLate ? l.lateTasks(lateCount) : l.noLateTasks,
                  style: AppText.title(context, size: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  hasLate ? l.reactQuickly : l.allOnTime,
                  style: AppText.body(context, size: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: p.soft),
        ],
      ),
    );
  }
}
