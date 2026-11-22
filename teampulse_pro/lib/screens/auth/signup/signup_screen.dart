import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/auth_service.dart';
import '../../../core/project_ui.dart';
import '../../../core/user_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/auth_header.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/switch_link.dart';
import '../../dashboard/shell/main_shell.dart';
import '../login/login_screen.dart';
import 'signup_form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  Future<String?> _register(
    BuildContext context,
    String name,
    String email,
    String password,
    String teamCode,
  ) async {
    final l = AppLocalizations.of(context)!;
    final error = await AuthService.register(
      fullName: name,
      email: email,
      password: password,
      workspaceCode: teamCode,
    );
    if (error != null) return authErrorText(error, l);
    if (!context.mounted) return null;

    final account = AuthService.current!;
    UserSession.fullName = account.fullName;
    UserSession.email = account.email;
    context.read<AppState>().start();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(title: l.signupTitle, subtitle: l.signupSubtitle),
              SignupForm(
                onSubmit: (n, e, p, c) => _register(context, n, e, p, c),
              ),
              const SizedBox(height: 12),
              SwitchLink(
                prefix: l.alreadyAccount,
                action: l.signIn,
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
