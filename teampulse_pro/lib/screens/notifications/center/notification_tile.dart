import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_palette.dart';
import '../../../core/app_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/notification_item.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/icon_tile.dart';

/// Une notification : icône par type, titre, message, point « non lu ».
class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final bool read;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.read,
    required this.onTap,
  });

  (IconData, Color) _style(NotifType t) {
    switch (t) {
      case NotifType.overdue:
        return (Icons.priority_high_rounded, AppColors.coral);
      case NotifType.reminder:
        return (Icons.alarm_rounded, AppColors.amber);
      case NotifType.assignment:
        return (Icons.person_add_alt_1_rounded, AppColors.primary);
    }
  }

  String _title(NotifType t, AppLocalizations l) {
    switch (t) {
      case NotifType.overdue:
        return l.notifOverdueTitle;
      case NotifType.reminder:
        return l.notifReminderTitle;
      case NotifType.assignment:
        return l.notifAssignTitle;
    }
  }

  String _message(AppNotification n, AppLocalizations l) {
    switch (n.type) {
      case NotifType.overdue:
        return l.notifOverdueMsg(n.taskTitle, n.days);
      case NotifType.reminder:
        if (n.days == 0) return l.notifReminderToday(n.taskTitle);
        if (n.days == 1) return l.notifReminderTomorrow(n.taskTitle);
        return l.notifReminderTwoDays(n.taskTitle);
      case NotifType.assignment:
        return l.notifAssignMsg(n.taskTitle, n.memberName ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final (icon, color) = _style(notification.type);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconTile(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(notification.type, l),
                  style: AppText.title(
                    context,
                    size: 15,
                    weight: read ? FontWeight.w600 : FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _message(notification, l),
                  style: AppText.body(context, size: 13),
                ),
              ],
            ),
          ),
          if (!read)
            Semantics(
              label: l.unreadLabel,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: p.primaryInk,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
