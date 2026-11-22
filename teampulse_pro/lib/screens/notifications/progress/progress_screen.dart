import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_palette.dart';
import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../core/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/status_chip.dart';
import 'chart_legend.dart';
import 'line_chart_painter.dart';
import 'progress_stat_card.dart';

/// Statistiques & progression : chiffres clés, alerte de retard et courbes.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _days = 7;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final series = s.statsSeries(_days);
    final latePercent = s.taskCount == 0
        ? 0
        : (s.tasksLate * 100 / s.taskCount).round();
    final last = series.isEmpty ? null : series.last;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.progressTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          PopupMenuButton<int>(
            tooltip: l.thisWeek,
            initialValue: _days,
            onSelected: (v) => setState(() => _days = v),
            itemBuilder: (_) => [
              PopupMenuItem(value: 7, child: Text(l.thisWeek)),
              PopupMenuItem(value: 30, child: Text(l.thisMonth)),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: StatusChip(
                label: _days == 7 ? l.thisWeek : l.thisMonth,
                color: AppColors.primary,
                icon: Icons.expand_more_rounded,
              ),
            ),
          ),
        ],
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
                ProgressStatCard(
                  label: l.statDone,
                  value: '${s.tasksDone}',
                  color: AppColors.mint,
                ),
                const SizedBox(width: AppSpace.m),
                ProgressStatCard(
                  label: l.statInProgress,
                  value: '${s.tasksActive}',
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: AppSpace.m),
            AppCard(
              color: AppColors.coral.withValues(alpha: p.isDark ? 0.14 : 0.1),
              borderColor: AppColors.coral.withValues(alpha: 0.45),
              padding: const EdgeInsets.all(18),
              child: Semantics(
                container: true,
                label: '${l.overdueLabel} : ${s.tasksLate}, '
                    '${l.percentOfTasks(latePercent)}',
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 18, color: p.coralInk),
                        const SizedBox(width: 6),
                        Text(l.overdueLabel, style: AppText.body(context)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${s.tasksLate}',
                          style: AppText.number(
                            context,
                            size: 34,
                            color: p.coralInk,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            l.percentOfTasks(latePercent),
                            style: AppText.title(
                              context,
                              size: 14,
                              weight: FontWeight.w600,
                              color: p.coralInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpace.m),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.taskEvolution,
                    style: AppText.heading(context, size: 17),
                  ),
                  const SizedBox(height: AppSpace.l),
                  Semantics(
                    label: last == null
                        ? l.taskEvolution
                        : '${l.taskEvolution}: ${l.legendDone} ${last.done}, '
                            '${l.legendActive} ${last.inProgress}, '
                            '${l.legendLate} ${last.overdue}',
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: LineChartPainter(series, gridColor: p.outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.daysAgo(_days),
                        style: AppText.body(context, size: 12),
                      ),
                      Text(l.today, style: AppText.body(context, size: 12)),
                    ],
                  ),
                  const SizedBox(height: AppSpace.m),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      ChartLegend(label: l.legendDone, color: AppColors.mint),
                      ChartLegend(
                        label: l.legendActive,
                        color: AppColors.primary,
                      ),
                      ChartLegend(label: l.legendLate, color: AppColors.coral),
                    ],
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
