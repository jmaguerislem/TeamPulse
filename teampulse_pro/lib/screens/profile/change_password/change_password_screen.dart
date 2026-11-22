import 'package:flutter/material.dart';

import '../../../core/auth_service.dart';
import '../../../core/project_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/content_width.dart';
import 'change_password_form.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  Future<String?> _save(
    BuildContext context,
    String oldPassword,
    String newPassword,
  ) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final error = await AuthService.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    if (error != null) return authErrorText(error, l);

    messenger.showSnackBar(SnackBar(content: Text(l.passwordChanged)));
    navigator.pop();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.passwordItem,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ContentWidth(
          child: ChangePasswordForm(onSubmit: (o, n) => _save(context, o, n)),
        ),
      ),
    );
  }
}
