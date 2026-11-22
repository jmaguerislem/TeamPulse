import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/date_field.dart';
import '../../../widgets/error_banner.dart';
import '../../../widgets/form_label.dart';
import '../../../widgets/primary_button.dart';

/// Données saisies dans le formulaire tâche.
class TaskDraft {
  final String title;
  final String description;
  final String projectId;
  final DateTime due;
  final TaskPriority priority;
  const TaskDraft({
    required this.title,
    required this.description,
    required this.projectId,
    required this.due,
    required this.priority,
  });
}

/// Formulaire de création / modification d'une tâche.
class TaskForm extends StatefulWidget {
  final Task? initial;
  final List<Project> projects;
  final String? defaultProjectId;
  final Future<String?> Function(TaskDraft draft) onSubmit;

  const TaskForm({
    super.key,
    this.initial,
    required this.projects,
    this.defaultProjectId,
    required this.onSubmit,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late String _projectId;
  late DateTime _due;
  late TaskPriority _priority;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _title = TextEditingController(text: t?.title ?? '');
    _desc = TextEditingController(text: t?.description ?? '');
    _projectId =
        t?.projectId ?? widget.defaultProjectId ?? widget.projects.first.id;
    _due = t?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _priority = t?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final error = await widget.onSubmit(
      TaskDraft(
        title: _title.text.trim(),
        description: _desc.text.trim(),
        projectId: _projectId,
        due: _due,
        priority: _priority,
      ),
    );
    if (!mounted) return; // l'écran a été fermé (enregistrement réussi)
    setState(() {
      _loading = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final editing = widget.initial != null;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormLabel(l.titleLabel, required: true, top: 8),
          TextFormField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: l.taskTitleHint),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.enterTaskTitle : null,
          ),
          FormLabel(l.description),
          TextFormField(
            controller: _desc,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: l.taskDescHint),
          ),
          FormLabel(l.projectLabelShort, required: true),
          DropdownButtonFormField<String>(
            initialValue: _projectId,
            isExpanded: true,
            decoration: const InputDecoration(),
            items: widget.projects
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (v) => setState(() => _projectId = v ?? _projectId),
          ),
          DateField(
            label: l.deadline,
            value: _due,
            onChanged: (d) => setState(() => _due = d),
          ),
          FormLabel(l.priorityLabel),
          DropdownButtonFormField<TaskPriority>(
            initialValue: _priority,
            isExpanded: true,
            decoration: const InputDecoration(),
            items: [
              DropdownMenuItem(
                value: TaskPriority.high,
                child: Text(l.priorityHigh),
              ),
              DropdownMenuItem(
                value: TaskPriority.medium,
                child: Text(l.priorityMedium),
              ),
              DropdownMenuItem(
                value: TaskPriority.low,
                child: Text(l.priorityLow),
              ),
            ],
            onChanged: (v) => setState(() => _priority = v ?? _priority),
          ),
          if (_error != null) ErrorBanner(_error!),
          const SizedBox(height: 28),
          PrimaryButton(
            label: editing ? l.saveChanges : l.createTheTask,
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
