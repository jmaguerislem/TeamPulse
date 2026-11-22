import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/app_tokens.dart';
import '../../../core/settings_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/filter_chips_bar.dart';
import '../../tasks/details/task_details_screen.dart';
import 'notification_tile.dart';

/// Centre de notifications : retards, rappels d'échéance, affectations.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _onlyUnread = false;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final prefs = context.watch<SettingsState>();
    final all = s.notificationsFor(
      overdue: prefs.notifOverdue,
      reminder: prefs.notifReminder,
      assignment: prefs.notifAssignment,
    );
    final unread = all.where((n) => !s.isRead(n.id)).length;
    final list = _onlyUnread ? all.where((n) => !s.isRead(n.id)).toList() : all;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.notificationsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => context.read<AppState>().markAllRead(),
              child: Text(l.markAllRead),
            ),
        ],
      ),
      body: ContentWidth(
        child: Column(
          children: [
            FilterChipsBar(
              labels: [l.filterAll, l.filterUnread(unread)],
              selected: _onlyUnread ? 1 : 0,
              onSelected: (i) => setState(() => _onlyUnread = i == 1),
            ),
            const SizedBox(height: AppSpace.m),
            Expanded(
              child: list.isEmpty
                  ? EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: l.noNotifications,
                      message: l.noNotificationsHint,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.page,
                        AppSpace.xs,
                        AppSpace.page,
                        AppSpace.xxl,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpace.m),
                      itemBuilder: (_, i) {
                        final n = list[i];
                        return NotificationTile(
                          notification: n,
                          read: s.isRead(n.id),
                          onTap: () {
                            context.read<AppState>().markRead(n.id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TaskDetailsScreen(taskId: n.taskId),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
