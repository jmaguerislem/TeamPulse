import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/app_tokens.dart';
import '../../core/settings_state.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/content_width.dart';
import '../../widgets/screen_title.dart';
import '../notifications/center/notifications_screen.dart';
import '../notifications/progress/progress_screen.dart';
import '../notifications/reports/reports_screen.dart';
import '../profile/overview/profile_screen.dart';
import 'more_tile.dart';

/// Onglet « Plus » : notifications, statistiques, rapports, profil.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<SettingsState>();
    final unread = context.watch<AppState>().unreadCountFor(
      overdue: prefs.notifOverdue,
      reminder: prefs.notifReminder,
      assignment: prefs.notifAssignment,
    );
    final l = AppLocalizations.of(context)!;

    return SafeArea(
      child: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpace.navClearance + 20),
          children: [
            ScreenTitle(l.moreTitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.page),
              child: Column(
                children: [
                  MoreTile(
                    icon: Icons.notifications_none_rounded,
                    title: l.notificationsTitle,
                    subtitle: l.notificationsSubtitle,
                    page: const NotificationsScreen(),
                    badge: unread,
                  ),
                  const SizedBox(height: AppSpace.m),
                  MoreTile(
                    icon: Icons.show_chart_rounded,
                    title: l.statsTile,
                    subtitle: l.statsTileSubtitle,
                    page: const ProgressScreen(),
                  ),
                  const SizedBox(height: AppSpace.m),
                  MoreTile(
                    icon: Icons.description_outlined,
                    title: l.reportsTile,
                    subtitle: l.reportsTileSubtitle,
                    page: const ReportsScreen(),
                  ),
                  const SizedBox(height: AppSpace.m),
                  MoreTile(
                    icon: Icons.person_outline_rounded,
                    title: l.profileTile,
                    subtitle: l.profileTileSubtitle,
                    page: const ProfileScreen(),
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
