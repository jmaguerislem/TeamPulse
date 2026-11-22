import 'package:flutter/material.dart';

import '../core/app_palette.dart';
import '../core/app_text.dart';
import '../core/app_tokens.dart';

/// Rangée de filtres défilante. La puce choisie est annoncée comme
/// « sélectionnée » aux lecteurs d'écran.
class FilterChipsBar extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  final EdgeInsetsGeometry padding;

  const FilterChipsBar({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpace.page),
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: padding,
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpace.s),
        itemBuilder: (_, i) {
          final isSelected = i == selected;
          final fg = isSelected
              ? (p.isDark ? p.background : Colors.white)
              : p.ink;
          return Semantics(
            button: true,
            selected: isSelected,
            child: AnimatedContainer(
              duration: AppMotion.fast(context),
              decoration: BoxDecoration(
                color: isSelected ? p.ink : p.card,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: isSelected ? p.ink : p.outline,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onSelected(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: AppText.title(context, size: 14, color: fg),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
