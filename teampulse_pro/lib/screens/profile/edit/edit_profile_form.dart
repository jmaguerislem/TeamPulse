import 'package:flutter/material.dart';

import '../../../core/auth_service.dart';
import '../../../core/user_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/error_banner.dart';
import '../../../widgets/form_label.dart';
import '../../../widgets/primary_button.dart';

/// Formulaire « Informations personnelles » (nom + e-mail).
class EditProfileForm extends StatefulWidget {
  /// Retourne un message d'erreur, ou `null` si l'enregistrement a réussi.
  final Future<String?> Function(String name, String email) onSubmit;
  const EditProfileForm({super.key, required this.onSubmit});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: UserSession.fullName);
    _email = TextEditingController(text: UserSession.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final error = await widget.onSubmit(_name.text, _email.text);
    if (!mounted) return; // l'écran a été fermé (enregistrement réussi)
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
            autofillHints: const [AutofillHints.name],
            decoration: InputDecoration(hintText: l.fullNameHint),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.enterFullName : null,
          ),
          FormLabel(l.emailLabel, required: true),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(hintText: l.emailHint),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l.enterEmail;
              if (!AuthService.isValidEmail(v)) return l.invalidEmail;
              return null;
            },
          ),
          if (_error != null) ErrorBanner(_error!),
          const SizedBox(height: 28),
          PrimaryButton(label: l.save, loading: _loading, onPressed: _submit),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
