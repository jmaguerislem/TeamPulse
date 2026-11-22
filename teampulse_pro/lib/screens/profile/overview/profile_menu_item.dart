import 'package:flutter/material.dart';

import '../../../core/app_palette.dart';
import '../../../core/app_text.dart';
import '../../../widgets/app_card.dart';

/// Ligne de réglage : titre, valeur actuelle (optionnelle) et flèche.
class ProfileMenuItem extends StatelessWidget {
  final String title;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.title,
    this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: p.primaryInk, size: 22),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: AppText.title(context, size: 16))),
          if (value != null)
            Flexible(
              child: Text(
                value!,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(context, size: 13),
              ),
            ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, color: p.soft, size: 22),
        ],
      ),
    );
  }
}
