import 'package:flutter/material.dart';

import '../core/app_palette.dart';

/// Pastille carrée arrondie avec une icône (listes, notifications, menus).
class IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const IconTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: context.palette.inkFor(color),
      ),
    );
  }
}
