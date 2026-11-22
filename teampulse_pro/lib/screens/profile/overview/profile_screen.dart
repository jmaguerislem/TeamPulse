import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_palette.dart';
import '../../../core/app_text.dart';
import '../../../core/app_tokens.dart';
import '../../../core/settings_state.dart';
import '../../../core/user_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/content_width.dart';
import '../../auth/welcome/welcome_screen.dart';
import '../appearance/appearance_screen.dart';
import '../change_password/change_password_screen.dart';
import '../edit/edit_profile_screen.dart';
import '../help/help_screen.dart';
import '../language/language_screen.dart';
import '../notification_prefs/notification_prefs_screen.dart';
import 'profile_header.dart';
import 'profile_menu_item.dart';
import '../../../core/auth_service.dart';
import 'team_code_card.dart';
import '../../../core/app_state.dart';

/// Profil et paramètres : infos, mot de passe, notifications, langue, thème.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() {});
  }

  Future<void> _logout() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showConfirmDialog(
      context,
      title: l.logoutTitle,
      body: l.logoutBody,
      confirmLabel: l.logoutConfirm,
    );
    if (!ok || !mounted) return;
    await AuthService.logout();
    if (!mounted) return;
    context.read<AppState>().unload();
    UserSession.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsState>();
    final l = AppLocalizations.of(context)!;
    final p = context.palette;

    final notifSummary = settings.activeNotifCount == 3
        ? l.notifSummaryAll
        : settings.activeNotifCount == 0
        ? l.notifSummaryNone
        : (settings.activeNotifCount == 1 && settings.notifOverdue)
        ? l.notifSummaryOverdue
        : l.notifSummaryCount(settings.activeNotifCount);
    final themeLabel = settings.themeMode == ThemeMode.light
        ? l.themeLight
        : settings.themeMode == ThemeMode.dark
        ? l.themeDark
        : l.themeSystem;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.profileTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.page,
            AppSpace.s,
            AppSpace.page,
            AppSpace.xxl,
          ),
          children: [
            const ProfileHeader(),
            if (AuthService.current != null) const TeamCodeCard(),
            ProfileMenuItem(
              title: l.personalInfo,
              icon: Icons.person_outline_rounded,
              onTap: () => _open(const EditProfileScreen()),
            ),
            ProfileMenuItem(
              title: l.passwordItem,
              icon: Icons.lock_outline_rounded,
              onTap: () => _open(const ChangePasswordScreen()),
            ),
            ProfileMenuItem(
              title: l.notifPrefsItem,
              value: notifSummary,
              icon: Icons.notifications_none_rounded,
              onTap: () => _open(const NotificationPrefsScreen()),
            ),
            ProfileMenuItem(
              title: l.languageItem,
              value: settings.language,
              icon: Icons.language_rounded,
              onTap: () => _open(const LanguageScreen()),
            ),
            ProfileMenuItem(
              title: l.appearanceItem,
              value: themeLabel,
              icon: Icons.palette_outlined,
              onTap: () => _open(const AppearanceScreen()),
            ),
            ProfileMenuItem(
              title: l.helpItem,
              icon: Icons.help_outline_rounded,
              onTap: () => _open(const HelpScreen()),
            ),
            const SizedBox(height: AppSpace.s),
            AppCard(
              onTap: _logout,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderColor: p.coralInk.withValues(alpha: 0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: p.coralInk, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l.logout,
                    style: AppText.title(context, size: 16, color: p.coralInk),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
