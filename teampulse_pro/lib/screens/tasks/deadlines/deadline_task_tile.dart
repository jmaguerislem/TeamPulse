import 'package:flutter/material.dart';

import '../../../core/app_text.dart';
import '../../../models/models.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/priority_chip.dart';
import '../details/task_details_screen.dart';

/// Tâche affichée sous le calendrier pour le jour sélectionné.
class DeadlineTaskTile extends StatelessWidget {
  final Task task;
  const DeadlineTaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      radius: 18,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskId: task.id)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(task.title, style: AppText.title(context))),
          const SizedBox(width: 8),
          PriorityChip(priority: task.priority),
        ],
      ),
    );
  }
}
