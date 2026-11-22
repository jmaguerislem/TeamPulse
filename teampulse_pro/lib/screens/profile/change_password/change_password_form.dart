import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../widgets/error_banner.dart';
import '../../../widgets/form_label.dart';
import '../../../widgets/password_field.dart';
import '../../../widgets/primary_button.dart';

/// Formulaire de changement de mot de passe (ancien, nouveau, confirmation).
class ChangePasswordForm extends StatefulWidget {
  /// Retourne un message d'erreur, ou `null` si le changement a réussi.
  final Future<String?> Function(String oldPassword, String newPassword)
  onSubmit;
  const ChangePasswordForm({super.key, required this.onSubmit});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final error = await widget.onSubmit(_old.text, _new.text);
    if (!mounted) return; // l'écran a été fermé (changement réussi)
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
          FormLabel(l.oldPasswordLabel, required: true, top: 8),
          PasswordField(
            controller: _old,
            hint: l.oldPasswordHint,
            autofillHints: const [AutofillHints.password],
            validator: (v) =>
                (v == null || v.isEmpty) ? l.enterOldPassword : null,
          ),
          FormLabel(l.newPasswordLabel, required: true),
          PasswordField(
            controller: _new,
            hint: l.passwordMinHint,
            autofillHints: const [AutofillHints.newPassword],
            validator: (v) =>
                (v == null || v.length < 8) ? l.passwordMinError : null,
          ),
          FormLabel(l.confirmPasswordLabel, required: true),
          PasswordField(
            controller: _confirm,
            hint: l.confirmPasswordHint,
            textInputAction: TextInputAction.done,
            onSubmitted: _submit,
            validator: (v) => v != _new.text ? l.passwordsDontMatch : null,
          ),
          if (_error != null) ErrorBanner(_error!),
          const SizedBox(height: 28),
          PrimaryButton(
            label: l.changePasswordButton,
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
