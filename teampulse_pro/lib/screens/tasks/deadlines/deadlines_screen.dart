import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../core/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/content_width.dart';
import 'calendar_grid.dart';
import 'deadline_task_tile.dart';

/// Calendrier des échéances : mois navigable + tâches du jour choisi.
class DeadlinesScreen extends StatefulWidget {
  const DeadlinesScreen({super.key});

  @override
  State<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends State<DeadlinesScreen> {
  static const _monthsFr = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];
  static const _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selected = DateTime(now.year, now.month, now.day);
  }

  void _changeMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final months = isEn ? _monthsEn : _monthsFr;
    final dayTasks = s.tasksOnDay(_selected);
    final isToday = CalendarGrid.same(_selected, DateTime.now());
    final dd = _selected.day.toString().padLeft(2, '0');
    final mm = _selected.month.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.deadlinesTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.page,
            AppSpace.s,
            AppSpace.page,
            AppSpace.xxl,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    liveRegion: true,
                    child: Text(
                      '${months[_month.month - 1]} ${_month.year}',
                      style: AppText.heading(context, size: 22),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l.previousMonth,
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => _changeMonth(-1),
                ),
                IconButton(
                  tooltip: l.nextMonth,
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.s),
            CalendarGrid(
              month: _month,
              selected: _selected,
              tasksOn: s.tasksOnDay,
              onSelect: (d) => setState(() => _selected = d),
            ),
            const SizedBox(height: AppSpace.xl),
            Text(
              isToday
                  ? l.todayCount(dayTasks.length)
                  : l.dateCount('$dd/$mm', dayTasks.length),
              style: AppText.heading(context, size: 18),
            ),
            const SizedBox(height: AppSpace.m),
            if (dayTasks.isEmpty)
              Text(l.noDeadlineThatDay, style: AppText.body(context))
            else
              ...dayTasks.map((t) => DeadlineTaskTile(task: t)),
          ],
        ),
      ),
    );
  }
}
