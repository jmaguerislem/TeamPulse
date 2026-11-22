import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_palette.dart';
import '../core/app_text.dart';
import '../core/app_tokens.dart';
import '../l10n/app_localizations.dart';

/// Barre de navigation flottante (5 onglets maximum, icône + libellé).
/// [moreBadge] affiche le nombre de notifications non lues sur « Plus ».
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int moreBadge;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.moreBadge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final items = [
      (Icons.home_rounded, Icons.home_outlined, l.navHome),
      (Icons.grid_view_rounded, Icons.grid_view_outlined, l.navProjects),
      (Icons.check_circle_rounded, Icons.check_circle_outline, l.navTasks),
      (Icons.groups_rounded, Icons.groups_outlined, l.navTeam),
      (Icons.more_horiz_rounded, Icons.more_horiz_rounded, l.navMore),
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: p.isDark ? p.outline : Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: p.isDark ? 0.0 : 0.14),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final selected = i == currentIndex;
            final color = selected ? p.primaryInk : p.soft;
            final showBadge = i == 4 && moreBadge > 0;
            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: showBadge
                    ? '${items[i].$3}, ${l.unreadCountSemantic(moreBadge)}'
                    : items[i].$3,
                onTap: () => onTap(i),
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: AppMotion.fast(context),
                    constraints: const BoxConstraints(minHeight: 56),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.14)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.l),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Badge(
                          isLabelVisible: showBadge,
                          label: Text('$moreBadge'),
                          backgroundColor: AppColors.coral,
                          textColor: Colors.white,
                          child: Icon(
                            selected ? items[i].$1 : items[i].$2,
                            color: color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].$3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.label(
                            context,
                            color: color,
                            size: 12,
                          ).copyWith(
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
