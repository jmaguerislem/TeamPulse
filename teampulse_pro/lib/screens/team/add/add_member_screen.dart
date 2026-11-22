import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/project_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/content_width.dart';
import 'member_form.dart';

class AddMemberScreen extends StatelessWidget {
  const AddMemberScreen({super.key});

  Future<String?> _add(BuildContext context, String name, String role) async {
    final l = AppLocalizations.of(context)!;
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);

    try {
      await state.createMember(name: name, role: role);
    } catch (e) {
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
            onSubmit: (name, role) => _add(context, name, role),
          ),
        ),
      ),
    );
  }
}
