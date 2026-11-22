import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_palette.dart';
import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../core/app_tokens.dart';
import '../../../core/project_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/priority_chip.dart';
import '../../../widgets/primary_button.dart';
import '../assign/assign_task_screen.dart';
import '../create/create_task_screen.dart';
import 'task_info_row.dart';
import 'task_attachments.dart';

/// Détail d'une tâche : infos, statut modifiable, assignation, édition.
class TaskDetailsScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  Future<void> _delete(BuildContext context, Task t) async {
    final l = AppLocalizations.of(context)!;
    final state = context.read<AppState>();
    final ok = await showConfirmDialog(
      context,
      title: l.deleteTaskTitle,
      body: l.deleteTaskBody(t.title),
      confirmLabel: l.delete,
    );
    if (!ok || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final removed = state.removeTask(t.id);
    Navigator.pop(context);
    if (removed == null) return;
    showUndoSnackBar(
      messenger,
      message: l.taskDeletedMsg(t.title),
      undoLabel: l.undo,
      onUndo: () => state.restoreTask(removed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final t = s.taskById(taskId);
    if (t == null) return const Scaffold(body: SizedBox());

    final project = s.projectById(t.projectId);
    final done = t.status == TaskStatus.done;
    final assignee = t.assignee == null ? null : s.memberById(t.assignee!);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.taskDetail,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            tooltip: l.editTask,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CreateTaskScreen(task: t)),
            ),
          ),
          IconButton(
            tooltip: l.delete,
            icon: Icon(Icons.delete_outline_rounded, color: p.coralInk),
            onPressed: () => _delete(context, t),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      t.title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PriorityChip(priority: t.priority),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l.projectNameLine(project?.name ?? l.deletedProject),
              style: AppText.body(context, size: 14),
            ),
            const SizedBox(height: 12),
            Text(
              t.description.isEmpty ? l.noDescription : t.description,
              style: AppText.body(context, size: 15),
            ),
            const SizedBox(height: AppSpace.xl),
            TaskInfoRow(
              label: l.deadline,
              value: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (t.isLate) ...[
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: p.coralInk,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    fmtDate(t.dueDate),
                    style: AppText.title(
                      context,
                      color: t.isLate ? p.coralInk : null,
                    ),
                  ),
                ],
              ),
            ),
            TaskInfoRow(
              label: l.status,
              value: DropdownButton<TaskStatus>(
                value: t.status,
                underline: const SizedBox(),
                isDense: true,
                style: AppText.title(context),
                items: TaskStatus.values
                    .map(
                      (st) => DropdownMenuItem(
                        value: st,
                        child: Text(taskStatusLabel(st, l)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    context.read<AppState>().setTaskStatus(t.id, v);
                  }
                },
              ),
            ),
            TaskInfoRow(
              label: l.assignedTo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AssignTaskScreen(taskId: t.id),
                ),
              ),
              value: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      assignee?.name ?? l.unassigned,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.title(context),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 20, color: p.soft),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.l),
            TaskAttachments(task: t),
            PrimaryButton(
              label: done ? l.reopenTask : l.markDone,
              icon: done ? Icons.replay_rounded : Icons.check_rounded,
              onPressed: () => context.read<AppState>().setTaskStatus(
                t.id,
                done ? TaskStatus.todo : TaskStatus.done,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
