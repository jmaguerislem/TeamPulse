import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_palette.dart';
import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_progress_bar.dart';

/// Carte « Résumé » (lignes libellé/valeur) + carte « Taux de réussite ».
class ReportSummaryCard extends StatelessWidget {
  final ReportData report;
  const ReportSummaryCard({super.key, required this.report});

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    Color? color,
    bool last = false,
  }) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: p.outline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: AppText.body(context, size: 14))),
          const SizedBox(width: 12),
          Text(
            value,
            style: AppText.title(
              context,
              size: 15,
              weight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final percent = (report.successRate * 100).round();

    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.summary, style: AppText.heading(context, size: 18)),
              const SizedBox(height: 4),
              _row(context, l.totalTasks, '${report.total}'),
              _row(context, l.statDone, '${report.done}', color: p.mintInk),
              _row(
                context,
                l.overdueLabel,
                '${report.overdue}',
                color: p.coralInk,
              ),
              _row(
                context,
                l.avgResolution,
                formatDuration(report.avgResolution, l),
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l.successRate, style: AppText.title(context, size: 16)),
                  Text(
                    '$percent %',
                    style: AppText.number(context, size: 20, color: p.mintInk),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppProgressBar(value: report.successRate, color: AppColors.mint),
            ],
          ),
        ),
      ],
    );
  }
}

String formatDuration(Duration? d, AppLocalizations l) {
  if (d == null) return '—';
  final days = d.inDays;
  final hours = d.inHours % 24;
  if (days > 0) return l.durationDaysHours(days, hours);
  if (d.inHours > 0) return l.durationHours(d.inHours);
  return l.durationMinutes(d.inMinutes);
}
