import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/date_field.dart';
import '../../../widgets/error_banner.dart';
import '../../../widgets/form_label.dart';
import '../../../widgets/primary_button.dart';

/// Données saisies dans le formulaire projet.
class ProjectDraft {
  final String name;
  final String description;
  final DateTime start;
  final DateTime deadline;
  final ProjectStatus status;
  const ProjectDraft({
    required this.name,
    required this.description,
    required this.start,
    required this.deadline,
    required this.status,
  });
}

/// Formulaire de création / modification d'un projet.
/// Si [initial] est fourni, les champs sont pré-remplis (mode édition).
class ProjectForm extends StatefulWidget {
  final Project? initial;
  final Future<String?> Function(ProjectDraft draft) onSubmit;
  const ProjectForm({super.key, this.initial, required this.onSubmit});

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late DateTime _start;
  late DateTime _deadline;
  late ProjectStatus _status;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name = TextEditingController(text: p?.name ?? '');
    _desc = TextEditingController(text: p?.description ?? '');
    _start = p?.startDate ?? DateTime.now();
    _deadline = p?.deadline ?? DateTime.now().add(const Duration(days: 30));
    _status = p?.status ?? ProjectStatus.inProgress;
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    final l = AppLocalizations.of(context)!;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    if (_deadline.isBefore(_start)) {
      setState(() => _error = l.deadlineAfterStart);
      return;
    }
    setState(() => _loading = true);
    final error = await widget.onSubmit(
      ProjectDraft(
        name: _name.text.trim(),
        description: _desc.text.trim(),
        start: _start,
        deadline: _deadline,
        status: _status,
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
          FormLabel(l.projectName, required: true, top: 8),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: l.projectNameHint),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.enterProjectName : null,
          ),
          FormLabel(l.description),
          TextFormField(
            controller: _desc,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: l.projectDescHint),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DateField(
                  label: l.startDate,
                  value: _start,
                  onChanged: (d) => setState(() => _start = d),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DateField(
                  label: l.deadline,
                  value: _deadline,
                  onChanged: (d) => setState(() => _deadline = d),
                ),
              ),
            ],
          ),
          FormLabel(l.status),
          DropdownButtonFormField<ProjectStatus>(
            initialValue: _status,
            isExpanded: true,
            decoration: const InputDecoration(),
            items: [
              DropdownMenuItem(
                value: ProjectStatus.inProgress,
                child: Text(l.filterInProgress),
              ),
              DropdownMenuItem(
                value: ProjectStatus.onHold,
                child: Text(l.filterOnHold),
              ),
              DropdownMenuItem(
                value: ProjectStatus.done,
                child: Text(l.statusDone),
              ),
            ],
            onChanged: (v) => setState(() => _status = v ?? _status),
          ),
          if (_error != null) ErrorBanner(_error!),
          const SizedBox(height: 28),
          PrimaryButton(
            label: editing ? l.saveChanges : l.createTheProject,
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
