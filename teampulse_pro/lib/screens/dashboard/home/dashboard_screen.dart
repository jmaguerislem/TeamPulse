import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../core/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/content_width.dart';
import '../../notifications/center/notifications_screen.dart';
import '../../projects/details/project_details_screen.dart';
import '../../tasks/deadlines/deadlines_screen.dart';
import 'dashboard_header.dart';
import 'deadline_tile.dart';
import 'late_alert_card.dart';
import 'progress_card.dart';
import 'stat_card.dart';

/// Onglet « Accueil » : avancement, statistiques, alertes et échéances.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static int _daysLeft(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(d.year, d.month, d.day).difference(today).inDays;
  }

  static String _dateLabel(DateTime d, int days, AppLocalizations l) {
    if (days < 0) return l.late;
    if (days == 0) return l.today;
    if (days == 1) return l.tomorrow;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final upcoming = s.upcomingProjects;

    return SafeArea(
      child: ContentWidth(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.page,
            AppSpace.l,
            AppSpace.page,
            AppSpace.navClearance,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardHeader(),
              const SizedBox(height: AppSpace.xl),
              ProgressCard(state: s),
              const SizedBox(height: AppSpace.l),
              Row(
                children: [
                  StatCard(
                    label: l.statProjects,
                    value: '${s.projectCount}',
                    icon: Icons.grid_view_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpace.m),
                  StatCard(
                    label: l.statTasks,
                    value: '${s.taskCount}',
                    icon: Icons.checklist_rounded,
                    color: AppColors.amber,
                  ),
                  const SizedBox(width: AppSpace.m),
                  StatCard(
                    label: l.statDone,
                    value: '${s.tasksDone}',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.mint,
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.l),
              LateAlertCard(
                lateCount: s.tasksLate,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
              ),
              const SizedBox(height: AppSpace.xl),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        l.upcomingDeadlines,
                        style: AppText.heading(context, size: 18),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DeadlinesScreen()),
                    ),
                    child: Text(l.seeAll),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s),
              if (upcoming.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.xl),
                  child: Center(
                    child: Text(l.noDeadlines, style: AppText.body(context)),
                  ),
                )
              else
                ...upcoming.map((p) {
                  final days = _daysLeft(p.deadline);
                  final urgent = days <= 2;
                  return DeadlineTile(
                    title: p.name,
                    subtitle:
                        '${_dateLabel(p.deadline, days, l)} · ${l.tasksCount(s.tasksOf(p.id).length)}',
                    badge: days < 0 ? l.late : (urgent ? l.urgent : l.soon),
                    badgeColor: urgent ? AppColors.coral : AppColors.amber,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailsScreen(projectId: p.id),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
