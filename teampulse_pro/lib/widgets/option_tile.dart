import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_palette.dart';
import '../core/app_text.dart';
import 'app_card.dart';

/// Choix unique dans une liste (langue, thème…). L'option active est
/// indiquée par la bordure ET une coche, annoncée « sélectionnée ».
class OptionTile extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: AppCard(
        onTap: onTap,
        margin: const EdgeInsets.only(bottom: 10),
        radius: 20,
        padding: const EdgeInsets.all(18),
        borderColor: selected ? AppColors.primary : null,
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: p.primaryInk),
              const SizedBox(width: 14),
            ],
            Expanded(child: Text(label, style: AppText.title(context, size: 16))),
            if (selected) Icon(Icons.check_circle_rounded, color: p.primaryInk),
          ],
        ),
      ),
    );
  }
}
