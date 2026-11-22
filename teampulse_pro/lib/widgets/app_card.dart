import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_palette.dart';
import '../core/app_tokens.dart';

/// Carte standard : fond du thème, ombre douce (clair) ou bordure (sombre).
/// Si [onTap] est fourni, la carte réagit au toucher (ondulation + sémantique
/// « bouton » pour les lecteurs d'écran).
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpace.l),
    this.margin,
    this.radius = AppRadius.l,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final shape = BorderRadius.circular(radius);

    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = InkWell(onTap: onTap, borderRadius: shape, child: content);
    }

    return Semantics(
      button: onTap != null,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: color ?? p.card,
          borderRadius: shape,
          border: Border.all(
            color: borderColor ?? (p.isDark ? p.outline : Colors.transparent),
          ),
          boxShadow: p.isDark
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: shape,
          clipBehavior: Clip.antiAlias,
          child: content,
        ),
      ),
    );
  }
}
