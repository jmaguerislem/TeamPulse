import 'package:flutter/material.dart';

import '../../../core/app_palette.dart';
import '../../../core/app_text.dart';
import '../../../core/project_ui.dart';
import '../../../models/models.dart';
import '../../../widgets/priority_chip.dart';
import '../details/task_details_screen.dart';

/// Carte du tableau Kanban : appui long puis glisser pour changer de colonne,
/// ou simple toucher pour ouvrir la tâche (alternative sans glisser-déposer).
class KanbanCard extends StatelessWidget {
  final Task task;
  const KanbanCard({super.key, required this.task});

  Widget _card(BuildContext context, {double opacity = 1}) {
    final p = context.palette;
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 232,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: AppText.title(context, size: 14)),
            const SizedBox(height: 6),
            Row(
              children: [
                if (task.isLate)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: p.coralInk,
                    ),
                  ),
                Text(
                  fmtDate(task.dueDate),
                  style: AppText.body(
                    context,
                    size: 12,
                    color: task.isLate ? p.coralInk : p.soft,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            PriorityChip(priority: task.priority),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Task>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.rotate(angle: 0.03, child: _card(context)),
      ),
      childWhenDragging: _card(context, opacity: 0.35),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskId: task.id)),
        ),
        child: _card(context),
      ),
    );
  }
}
