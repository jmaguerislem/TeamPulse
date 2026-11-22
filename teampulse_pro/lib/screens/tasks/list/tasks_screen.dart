import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_palette.dart';
import '../../../core/app_state.dart';
import '../../../core/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/filter_chips_bar.dart';
import '../../../widgets/gradient_fab.dart';
import '../../../widgets/screen_title.dart';
import '../../../widgets/search_field.dart';
import '../create/create_task_screen.dart';
import '../kanban/kanban_screen.dart';
import 'task_card.dart';

/// Onglet « Tâches » : recherche, filtres par statut et accès au Kanban.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _filter = 0;
  String _query = '';

  List<Task> _apply(List<Task> all) {
    final q = _query.trim().toLowerCase();
    final list = all.where((t) {
      final matchesFilter = switch (_filter) {
        1 => t.status == TaskStatus.todo,
        2 => t.status == TaskStatus.inProgress,
        3 => t.status == TaskStatus.done,
        _ => true,
      };
      return matchesFilter && (q.isEmpty || t.title.toLowerCase().contains(q));
    }).toList();
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  void _create(AppState s) {
    final l = AppLocalizations.of(context)!;
    if (s.projects.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.createProjectFirst)));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final list = _apply(s.tasks);

    return SafeArea(
      child: ContentWidth(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenTitle(
                  l.navTasks,
                  trailing: IconButton(
                    tooltip: l.kanbanBoard,
                    iconSize: 26,
                    icon: Icon(Icons.view_kanban_outlined, color: p.primaryInk),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const KanbanScreen()),
                    ),
                  ),
                ),
                SearchField(
                  hint: l.searchTasks,
                  onChanged: (v) => setState(() => _query = v),
                ),
                FilterChipsBar(
                  labels: [
                    l.filterAllFem,
                    l.taskTodo,
                    l.filterInProgress,
                    l.taskStatusDone,
                  ],
                  selected: _filter,
                  onSelected: (i) => setState(() => _filter = i),
                ),
                const SizedBox(height: AppSpace.m),
                Expanded(
                  child: s.tasks.isEmpty
                      ? EmptyState(
                          icon: Icons.checklist_rounded,
                          title: l.noTaskHere,
                          message: l.noTaskHint,
                          actionLabel: l.newTask,
                          onAction: () => _create(s),
                        )
                      : list.isEmpty
                      ? EmptyState(
                          icon: Icons.search_off_rounded,
                          title: l.noResults,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.page,
                            AppSpace.xs,
                            AppSpace.page,
                            AppSpace.navClearance + 20,
                          ),
                          itemCount: list.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpace.m),
                          itemBuilder: (_, i) => TaskCard(task: list[i]),
                        ),
                ),
              ],
            ),
            Positioned(
              right: AppSpace.page,
              bottom: AppSpace.fabBottom,
              child: GradientFab(tooltip: l.newTask, onPressed: () => _create(s)),
            ),
          ],
        ),
      ),
    );
  }
}
