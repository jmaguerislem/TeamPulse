import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../../../core/app_state.dart';
import '../../../core/project_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/content_width.dart';
import 'member_form.dart';

/// Ajout d'un membre par la cheffe de projet. Le membre pourra ensuite créer
/// son compte avec cet e-mail et le code d'équipe, et retrouver ses tâches.
class AddMemberScreen extends StatelessWidget {
  const AddMemberScreen({super.key});

  Future<String?> _add(
    BuildContext context,
    String name,
    String role,
    String email,
  ) async {
    final l = AppLocalizations.of(context)!;
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);

    try {
      await state.createMember(name: name, role: role, email: email);
    } catch (e) {
      if (e is ApiException && e.status == 409) return l.memberEmailExists;
      if (e is ApiException && e.status == 403) return l.onlyLeadCanManage;
      return apiErrorText(e, l);
    }
    navigator.pop();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.newMember, style: Theme.of(context).textTheme.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ContentWidth(
          child: MemberForm(
            onSubmit: (name, role, email) => _add(context, name, role, email),
          ),
        ),
      ),
    );
  }
}
