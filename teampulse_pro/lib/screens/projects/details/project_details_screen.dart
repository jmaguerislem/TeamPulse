import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_palette.dart';
import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../core/app_tokens.dart';
import '../../../core/project_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/filter_chips_bar.dart';
import '../../tasks/deadlines/deadlines_screen.dart';
import '../create/create_project_screen.dart';
import 'project_header_card.dart';
import 'project_members_tab.dart';
import 'project_tasks_tab.dart';

/// Détail d'un projet : en-tête, onglets (description / tâches / membres),
/// résumé et accès au calendrier des échéances.
class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;
  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  int _tab = 0;

  Future<void> _delete() async {
    final l = AppLocalizations.of(context)!;
    final state = context.read<AppState>();
    final p = state.projectById(widget.projectId);
    if (p == null) return;

    final ok = await showConfirmDialog(
      context,
      title: l.deleteProjectTitle,
      body: l.deleteProjectBody(p.name),
      confirmLabel: l.delete,
    );
    if (!ok || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final removed = state.removeProject(p.id);
    Navigator.pop(context);
    if (removed == null) return;
    showUndoSnackBar(
      messenger,
      message: l.projectDeletedMsg(p.name),
      undoLabel: l.undo,
      onUndo: () => state.restoreProject(removed.project, removed.tasks),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final pal = context.palette;
    final project = s.projectById(widget.projectId);
    if (project == null) return const Scaffold(body: SizedBox());

    final info = projectStatusInfo(s, project, l);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.projectDetails,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            tooltip: l.editProject,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateProjectScreen(project: project),
              ),
            ),
          ),
          IconButton(
            tooltip: l.delete,
            icon: Icon(Icons.delete_outline_rounded, color: pal.coralInk),
            onPressed: _delete,
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
            ProjectHeaderCard(
              project: project,
              status: info,
              progress: s.projectProgress(project.id),
            ),
            const SizedBox(height: AppSpace.l),
            FilterChipsBar(
              labels: [l.tabDescription, l.tabTasks, l.tabMembers],
              selected: _tab,
              padding: EdgeInsets.zero,
              onSelected: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: AppSpace.m),
            if (_tab == 0)
              Text(
                project.description.isEmpty
                    ? l.noDescription
                    : project.description,
                style: AppText.body(context, size: 15),
              ),
            if (_tab == 1) ProjectTasksTab(project: project),
            if (_tab == 2) ProjectMembersTab(project: project),
            const SizedBox(height: AppSpace.xl),
            AppCard(
              radius: 20,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.tasksDoneLabel(s.tasksDoneOf(project.id)),
                          style: AppText.title(context, size: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.lateCountLabel(s.tasksLateOf(project.id)),
                          style: AppText.body(
                            context,
                            size: 13,
                            color: s.tasksLateOf(project.id) > 0
                                ? pal.coralInk
                                : pal.soft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.m),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeadlinesScreen()),
              ),
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(l.viewCalendar),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: pal.primaryInk,
                side: BorderSide(color: pal.primaryInk.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
