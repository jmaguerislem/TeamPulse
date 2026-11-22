import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_palette.dart';
import '../../../core/app_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';

/// Grille mensuelle. Un point corail marque les jours qui ont une échéance ;
/// le jour sélectionné est plein, aujourd'hui est cerclé.
class CalendarGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selected;
  final List<Task> Function(DateTime day) tasksOn;
  final ValueChanged<DateTime> onSelect;

  const CalendarGrid({
    super.key,
    required this.month,
    required this.selected,
    required this.tasksOn,
    required this.onSelect,
  });

  static bool same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final weekdays = [
      l.weekdayMon,
      l.weekdayTue,
      l.weekdayWed,
      l.weekdayThu,
      l.weekdayFri,
      l.weekdaySat,
      l.weekdaySun,
    ];
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final offset = DateTime(month.year, month.month, 1).weekday - 1;
    final today = DateTime.now();

    return Column(
      children: [
        Row(
          children: weekdays
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(d, style: AppText.label(context, color: p.soft, size: 13)),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: offset + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (_, i) {
            if (i < offset) return const SizedBox();
            final day = DateTime(month.year, month.month, i - offset + 1);
            final isSelected = same(day, selected);
            final isToday = same(day, today);
            final count = tasksOn(day).length;

            return Semantics(
              button: true,
              selected: isSelected,
              label: '${day.day}${count > 0 ? ', $count' : ''}',
              onTap: () => onSelect(day),
              excludeSemantics: true,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => onSelect(day),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : null,
                    border: isToday && !isSelected
                        ? Border.all(color: p.primaryInk, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: AppText.title(
                          context,
                          size: 14,
                          weight: FontWeight.w600,
                          color: isSelected ? Colors.white : p.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: count > 0
                              ? (isSelected ? Colors.white : AppColors.coral)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
