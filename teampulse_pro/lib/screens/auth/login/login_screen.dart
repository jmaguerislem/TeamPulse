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
import '../signup/signup_screen.dart';
import 'login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<String?> _login(
    BuildContext context,
    String email,
    String password,
  ) async {
    final l = AppLocalizations.of(context)!;
    final error = await AuthService.login(email, password);
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
              AuthHeader(title: l.loginTitle, subtitle: l.loginSubtitle),
              LoginForm(onSubmit: (e, p) => _login(context, e, p)),
              const SizedBox(height: 12),
              SwitchLink(
                prefix: l.noAccountYet,
                action: l.createAccount,
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
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
