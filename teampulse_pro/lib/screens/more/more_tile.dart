import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_palette.dart';
import '../../core/app_text.dart';
import '../../widgets/app_card.dart';
import '../../widgets/icon_tile.dart';

/// Ligne du menu « Plus » : icône, titre, sous-titre, badge optionnel.
class MoreTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget page;
  final int badge;

  const MoreTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.page,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Row(
        children: [
          IconTile(icon: icon, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.title(context, size: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppText.body(context, size: 13)),
              ],
            ),
          ),
          if (badge > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          Icon(Icons.chevron_right_rounded, color: p.soft),
        ],
      ),
    );
  }
}
