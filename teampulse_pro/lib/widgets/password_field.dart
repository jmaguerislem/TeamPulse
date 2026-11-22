import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Champ mot de passe avec bouton afficher / masquer (accessible).
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final VoidCallback? onSubmitted;

  const PasswordField({
    super.key,
    required this.controller,
    required this.hint,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onSubmitted,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hint,
        suffixIcon: IconButton(
          tooltip: _hidden ? l.showPassword : l.hidePassword,
          icon: Icon(
            _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _hidden = !_hidden),
        ),
      ),
    );
  }
}
