import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../l10n/app_localizations.dart';

/// Grande carte « Avancement global » avec anneau de progression.
class ProgressCard extends StatelessWidget {
  final AppState state;
  const ProgressCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final percent = (state.globalProgress * 100).round();
    const onHero = Colors.white;
    final onHeroSoft = Colors.white.withValues(alpha: 0.88);

    return Semantics(
      container: true,
      label: '${l.globalProgress} $percent %',
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: AppColors.gradientHero,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: CircularProgressIndicator(
                        value: state.globalProgress,
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withValues(alpha: 0.22),
                        valueColor: const AlwaysStoppedAnimation(AppColors.mint),
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: AppText.number(context, size: 22, color: onHero),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.globalProgress,
                    style: AppText.heading(context, size: 18, color: onHero),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.projectsInProgress(state.projectsInProgress),
                    style: AppText.body(context, size: 14, color: onHeroSoft),
                  ),
                  Text(
                    l.projectsDoneCount(state.projectsDone),
                    style: AppText.body(context, size: 14, color: onHeroSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
