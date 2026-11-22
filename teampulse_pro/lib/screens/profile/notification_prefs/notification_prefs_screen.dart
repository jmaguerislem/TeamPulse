import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_text.dart';
import '../../../core/settings_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/content_width.dart';

/// Préférences : quelles alertes afficher (retards, rappels, affectations).
class NotificationPrefsScreen extends StatelessWidget {
  const NotificationPrefsScreen({super.key});

  Widget _switch(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        activeThumbColor: AppColors.primary,
        value: value,
        onChanged: onChanged,
        title: Text(title, style: AppText.title(context, size: 16)),
        subtitle: Text(subtitle, style: AppText.body(context, size: 13)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsState>();
    final read = context.read<SettingsState>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.notifPrefsItem,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _switch(context, l.prefOverdueTitle, l.prefOverdueSub,
                s.notifOverdue, read.setNotifOverdue),
            _switch(context, l.prefReminderTitle, l.prefReminderSub,
                s.notifReminder, read.setNotifReminder),
            _switch(context, l.prefAssignTitle, l.prefAssignSub,
                s.notifAssignment, read.setNotifAssignment),
          ],
        ),
      ),
    );
  }
}
