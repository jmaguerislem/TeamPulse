import 'package:flutter/material.dart';

import '../../../core/auth_service.dart';
import '../../../core/project_ui.dart';
import '../../../core/user_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/content_width.dart';
import 'edit_profile_form.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  Future<String?> _save(BuildContext context, String name, String email) async {
    final l = AppLocalizations.of(context)!;
    // On garde ces objets avant l'attente réseau (le contexte peut changer).
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final error = await AuthService.updateProfile(
      newName: name,
      newEmail: email,
    );
    if (error != null) return authErrorText(error, l);

    final account = AuthService.current!;
    UserSession.fullName = account.fullName;
    UserSession.email = account.email;
    messenger.showSnackBar(SnackBar(content: Text(l.profileUpdated)));
    navigator.pop();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.personalInfo,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ContentWidth(
          child: EditProfileForm(onSubmit: (n, e) => _save(context, n, e)),
        ),
      ),
    );
  }
}
