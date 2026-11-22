import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_palette.dart';
import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../core/project_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/member_avatar.dart';
import '../../../widgets/priority_chip.dart';
import '../details/task_details_screen.dart';

/// Carte d'une tâche : titre, priorité, projet, échéance, alerte de retard
/// et membre assigné.
class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final project = s.projectById(task.projectId);
    final assignee = task.assignee == null ? null : s.memberById(task.assignee!);
    final done = task.status == TaskStatus.done;

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskId: task.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.title(context, size: 16).copyWith(
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PriorityChip(priority: task.priority),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.projectDateLine(
              project?.name ?? l.deletedProject,
              fmtDate(task.dueDate),
            ),
            style: AppText.body(context, size: 13),
          ),
          if (task.isLate || assignee != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (task.isLate) ...[
                  Icon(Icons.warning_amber_rounded, size: 16, color: p.coralInk),
                  const SizedBox(width: 4),
                  Text(
                    l.late,
                    style: AppText.label(context, color: p.coralInk, size: 13),
                  ),
                ],
                const Spacer(),
                if (assignee != null) MemberAvatar(member: assignee, size: 28),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
