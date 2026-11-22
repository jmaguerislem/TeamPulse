import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_palette.dart';
import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../core/project_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/app_card.dart';
import '../../tasks/create/create_task_screen.dart';
import '../../tasks/details/task_details_screen.dart';

/// Onglet « Tâches » d'un projet : cases à cocher + accès au détail.
class ProjectTasksTab extends StatelessWidget {
  final Project project;
  const ProjectTasksTab({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final tasks = s.tasksOf(project.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateTaskScreen(projectId: project.id),
            ),
          ),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(l.addTask),
        ),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l.noTaskForProject, style: AppText.body(context)),
          )
        else
          ...tasks.map((t) {
            final done = t.status == TaskStatus.done;
            return AppCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              radius: 18,
              child: Row(
                children: [
                  Checkbox(
                    value: done,
                    activeColor: AppColors.mint,
                    checkColor: AppColors.navy,
                    side: BorderSide(color: p.soft, width: 1.5),
                    onChanged: (v) => context.read<AppState>().setTaskStatus(
                      t.id,
                      v == true ? TaskStatus.done : TaskStatus.todo,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailsScreen(taskId: t.id),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: AppText.title(
                                context,
                                size: 15,
                                weight: FontWeight.w600,
                              ).copyWith(
                                decoration:
                                    done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.isLate
                                  ? l.lateOn(fmtDate(t.dueDate))
                                  : fmtDate(t.dueDate),
                              style: AppText.body(
                                context,
                                size: 12,
                                color: t.isLate ? p.coralInk : p.soft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 20),
                  const SizedBox(width: 8),
                ],
              ),
            );
          }),
      ],
    );
  }
}
