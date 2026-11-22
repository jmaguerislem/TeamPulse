import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../widgets/error_banner.dart';
import '../../../widgets/form_label.dart';
import '../../../widgets/primary_button.dart';

/// Formulaire d'ajout d'un membre (nom + rôle).
class MemberForm extends StatefulWidget {
  final Future<String?> Function(String name, String role) onSubmit;
  const MemberForm({super.key, required this.onSubmit});

  @override
  State<MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _role = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final error = await widget.onSubmit(_name.text.trim(), _role.text.trim());
    if (!mounted) return; // l'écran a été fermé (ajout réussi)
    setState(() {
      _loading = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormLabel(l.fullNameLabel, required: true, top: 8),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: l.memberNameHint),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.enterMemberName : null,
          ),
          FormLabel(l.roleLabel, required: true),
          TextFormField(
            controller: _role,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(hintText: l.roleHint),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.enterMemberRole : null,
          ),
          if (_error != null) ErrorBanner(_error!),
          const SizedBox(height: 28),
          PrimaryButton(
            label: l.addTheMember,
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
