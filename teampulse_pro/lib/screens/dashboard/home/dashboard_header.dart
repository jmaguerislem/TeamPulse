import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../core/settings_state.dart';
import '../../../core/user_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/member_avatar.dart';
import '../../notifications/center/notifications_screen.dart';
import '../../profile/overview/profile_screen.dart';

/// En-tête : salutation, cloche de notifications (avec badge) et avatar.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final prefs = context.watch<SettingsState>();
    final unread = context.watch<AppState>().unreadCountFor(
      overdue: prefs.notifOverdue,
      reminder: prefs.notifReminder,
      assignment: prefs.notifAssignment,
    );

    return ValueListenableBuilder<int>(
      valueListenable: UserSession.changes,
      builder: (context, _, _) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UserSession.firstName.isEmpty
                      ? l.hello
                      : l.helloName(UserSession.firstName),
                  style: AppText.body(context, size: 15),
                ),
                const SizedBox(height: 2),
                Semantics(
                  header: true,
                  child: Text(
                    l.yourActivity,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l.notificationsTitle,
            iconSize: 26,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: l.profileTitle,
            child: InkResponse(
              radius: 28,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: Semantics(
                button: true,
                label: l.profileTitle,
                excludeSemantics: true,
                child: UserAvatar(initials: UserSession.initials, size: 44),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
