import 'package:flutter/material.dart';

import '../../../core/auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/error_banner.dart';
import '../../../widgets/form_label.dart';
import '../../../widgets/password_field.dart';
import '../../../widgets/primary_button.dart';

/// Formulaire d'inscription. [onSubmit] retourne un message d'erreur,
/// ou `null` si le compte a été créé. Le code d'équipe est facultatif :
/// vide = on crée une nouvelle équipe, rempli = on rejoint une équipe.
class SignupForm extends StatefulWidget {
  final Future<String?> Function(
    String name,
    String email,
    String password,
    String teamCode,
  )
  onSubmit;
  const SignupForm({super.key, required this.onSubmit});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _teamCode = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _teamCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final error = await widget.onSubmit(
      _name.text,
      _email.text,
      _password.text,
      _teamCode.text,
    );
    if (!mounted) return; // l'écran a changé (inscription réussie)
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
            FormLabel(l.fullNameLabel, required: true),
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
              hint: l.passwordMinHint,
              autofillHints: const [AutofillHints.newPassword],
              validator: (v) =>
                  (v == null || v.length < 8) ? l.passwordMinError : null,
            ),
            FormLabel(l.teamCodeLabel),
            TextFormField(
              controller: _teamCode,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(hintText: l.teamCodeHint),
            ),
            if (_error != null) ErrorBanner(_error!),
            const SizedBox(height: 28),
            PrimaryButton(
              label: l.signUp,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
