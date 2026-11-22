import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Bouton d'action flottant (+) aux couleurs de la marque.
/// [tooltip] sert aussi de libellé pour les lecteurs d'écran.
class GradientFab extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final IconData icon;

  const GradientFab({
    super.key,
    required this.onPressed,
    required this.tooltip,
    this.icon = Icons.add_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        onTap: onPressed,
        excludeSemantics: true,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.gradientPrimary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}
