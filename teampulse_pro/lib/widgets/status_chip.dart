import 'package:flutter/material.dart';

import '../core/app_palette.dart';
import '../core/app_text.dart';

/// Petite pastille de statut. Le texte utilise une variante foncée (ou claire
/// en mode sombre) de l'accent pour rester lisible ; le sens n'est jamais
/// porté par la couleur seule : il y a toujours un libellé.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ink = context.palette.inkFor(color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: ink),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.label(context, color: ink),
            ),
          ),
        ],
      ),
    );
  }
}
