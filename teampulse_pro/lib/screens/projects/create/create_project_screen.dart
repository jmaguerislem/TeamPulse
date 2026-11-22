import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/project_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/content_width.dart';
import 'project_form.dart';

/// Création d'un projet. Si [project] est fourni, l'écran sert à le modifier.
class CreateProjectScreen extends StatelessWidget {
  final Project? project;
  const CreateProjectScreen({super.key, this.project});

  Future<String?> _save(BuildContext context, ProjectDraft d) async {
    final l = AppLocalizations.of(context)!;
    // On garde ces objets avant l'attente réseau (le contexte peut changer).
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      if (project == null) {
        await state.createProject(
          name: d.name,
          description: d.description,
          startDate: d.start,
          deadline: d.deadline,
          status: d.status,
        );
      } else {
        await state.editProject(
          project!.id,
          name: d.name,
          description: d.description,
          startDate: d.start,
          deadline: d.deadline,
          status: d.status,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project == null ? l.createProject : l.editProject,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ContentWidth(
          child: ProjectForm(
            initial: project,
            onSubmit: (d) => _save(context, d),
          ),
        ),
      ),
    );
  }
}
