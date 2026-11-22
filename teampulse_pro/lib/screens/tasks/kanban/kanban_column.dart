import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_palette.dart';
import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../core/project_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import 'kanban_card.dart';

/// Colonne du Kanban (À faire / En cours / Terminée) : zone de dépôt.
class KanbanColumn extends StatelessWidget {
  final TaskStatus status;
  final List<Task> tasks;
  const KanbanColumn({super.key, required this.status, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = context.palette;

    return DragTarget<Task>(
      onWillAcceptWithDetails: (d) => d.data.status != status,
      onAcceptWithDetails: (d) =>
          context.read<AppState>().setTaskStatus(d.data.id, status),
      builder: (context, candidate, _) {
        final hovering = candidate.isNotEmpty;
        return Container(
          width: 256,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hovering
                ? AppColors.primary.withValues(alpha: 0.2)
                : p.cardAlt,
            borderRadius: BorderRadius.circular(24),
            border: hovering
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    taskStatusLabel(status, l),
                    style: AppText.heading(context, size: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${tasks.length}',
                      style: AppText.label(context, color: p.primaryInk),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          l.dropTaskHere,
                          textAlign: TextAlign.center,
                          style: AppText.body(context, size: 13),
                        ),
                      )
                    : ListView.separated(
                        itemCount: tasks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => KanbanCard(task: tasks[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
