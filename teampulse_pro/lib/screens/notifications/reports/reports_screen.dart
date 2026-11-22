import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../core/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/filter_chips_bar.dart';
import '../../../widgets/primary_button.dart';
import 'report_summary_card.dart';
import 'report_pdf.dart';

/// Rapports : vue globale ou par projet, avec taux de réussite.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _tab = 0;
  String? _projectId;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final projects = s.projects;

    final String? pid = _tab == 0
        ? null
        : (_projectId ?? (projects.isEmpty ? null : projects.first.id));
    final noProject = _tab == 1 && pid == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.reportsTitle,
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
            FilterChipsBar(
              labels: [l.tabGlobal, l.tabByProject],
              selected: _tab,
              padding: EdgeInsets.zero,
              onSelected: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: AppSpace.l),
            if (_tab == 1 && projects.isNotEmpty) ...[
              AppCard(
                radius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: pid,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: AppText.title(context),
                  items: projects
                      .map(
                        (p) =>
                            DropdownMenuItem(value: p.id, child: Text(p.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _projectId = v),
                ),
              ),
              const SizedBox(height: AppSpace.l),
            ],
            if (noProject)
              SizedBox(
                height: 280,
                child: EmptyState(
                  icon: Icons.folder_open_rounded,
                  title: l.noProjectYet,
                ),
              )
            else ...[
              ReportSummaryCard(report: s.reportFor(pid)),
              const SizedBox(height: 22),
              PrimaryButton(
                label: l.exportPdf,
                icon: Icons.picture_as_pdf_outlined,
                onPressed: () {
                  final r = s.reportFor(pid);
                  exportReportPdf(
                    title: l.reportsTitle,
                    subtitle: pid == null
                        ? l.tabGlobal
                        : (s.projectById(pid)?.name ?? ''),
                    rows: [
                      (l.totalTasks, '${r.total}'),
                      (l.statDone, '${r.done}'),
                      (l.overdueLabel, '${r.overdue}'),
                      (l.avgResolution, formatDuration(r.avgResolution, l)),
                      (l.successRate, '${(r.successRate * 100).round()} %'),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
