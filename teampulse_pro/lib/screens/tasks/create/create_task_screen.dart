import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/project_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/content_width.dart';
import 'task_form.dart';

/// Création d'une tâche. Si [task] est fourni, l'écran sert à la modifier.
/// [projectId] pré-sélectionne le projet (quand on vient d'un projet).
class CreateTaskScreen extends StatelessWidget {
  final String? projectId;
  final Task? task;
  const CreateTaskScreen({super.key, this.projectId, this.task});

  Future<String?> _save(BuildContext context, TaskDraft d) async {
    final l = AppLocalizations.of(context)!;
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      if (task == null) {
        await state.createTask(
          projectId: d.projectId,
          title: d.title,
          description: d.description,
          dueDate: d.due,
          priority: d.priority,
        );
      } else {
        await state.editTask(
          task!.id,
          projectId: d.projectId,
          title: d.title,
          description: d.description,
          dueDate: d.due,
          priority: d.priority,
        );
        messenger.showSnackBar(SnackBar(content: Text(l.changesSaved)));
      }
    } catch (e) {
      return apiErrorText(e, l);
    }
    navigator.pop();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final projects = context.watch<AppState>().projects;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          task == null ? l.newTask : l.editTask,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: projects.isEmpty
          ? Center(child: Text(l.createProjectFirst))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ContentWidth(
                child: TaskForm(
                  initial: task,
                  projects: projects,
                  defaultProjectId: projectId,
                  onSubmit: (d) => _save(context, d),
                ),
              ),
            ),
    );
  }
}
