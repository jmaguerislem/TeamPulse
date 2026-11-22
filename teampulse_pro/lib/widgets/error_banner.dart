import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_palette.dart';
import '../core/app_text.dart';

/// Bandeau d'erreur sous un formulaire : icône + texte (pas seulement de la
/// couleur), annoncé automatiquement par les lecteurs d'écran.
class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.coral.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.coral.withValues(alpha: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, color: p.coralInk, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppText.title(
                  context,
                  size: 13,
                  weight: FontWeight.w600,
                  color: p.coralInk,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
