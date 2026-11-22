import 'package:flutter/material.dart';

import '../../../core/auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/error_banner.dart';
import '../../../widgets/form_label.dart';
import '../../../widgets/password_field.dart';
import '../../../widgets/primary_button.dart';

/// Formulaire de connexion. [onSubmit] retourne un message d'erreur,
/// ou `null` si la connexion a réussi.
class LoginForm extends StatefulWidget {
  final Future<String?> Function(String email, String password) onSubmit;
  const LoginForm({super.key, required this.onSubmit});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final error = await widget.onSubmit(_email.text, _password.text);
    if (!mounted) return; // l'écran a changé (connexion réussie)
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
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormLabel(l.emailLabel, required: true),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(hintText: l.emailHint),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l.enterEmail;
                if (!AuthService.isValidEmail(v)) return l.invalidEmail;
                return null;
              },
            ),
            FormLabel(l.passwordLabel, required: true),
            PasswordField(
              controller: _password,
              hint: l.yourPasswordHint,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: _submit,
              validator: (v) =>
                  (v == null || v.isEmpty) ? l.enterPassword : null,
            ),
            if (_error != null) ErrorBanner(_error!),
            const SizedBox(height: 28),
            PrimaryButton(
              label: l.signIn,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
