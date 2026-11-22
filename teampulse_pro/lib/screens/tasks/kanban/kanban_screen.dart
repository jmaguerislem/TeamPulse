import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import 'kanban_column.dart';

/// Tableau Kanban : 3 colonnes défilantes horizontalement.
class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

  static const _columns = [
    TaskStatus.todo,
    TaskStatus.inProgress,
    TaskStatus.done,
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.kanbanBoard,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.touch_app_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l.kanbanHint, style: AppText.body(context, size: 13)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: _columns
                  .map(
                    (status) => KanbanColumn(
                      status: status,
                      tasks: s.tasks.where((t) => t.status == status).toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
