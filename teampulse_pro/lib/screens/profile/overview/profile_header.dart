import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_text.dart';
import '../../../core/user_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/member_avatar.dart';
import '../../../widgets/status_chip.dart';

/// Carte du haut du profil : avatar, nom, e-mail et rôle.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final name = UserSession.fullName.isEmpty
        ? l.defaultUserName
        : UserSession.fullName;
    final email = UserSession.email.isEmpty ? l.noEmail : UserSession.email;

    return AppCard(
      radius: 26,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          UserAvatar(initials: UserSession.initials, size: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppText.heading(context, size: 19)),
                const SizedBox(height: 2),
                Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(context, size: 13),
                ),
                const SizedBox(height: 8),
                StatusChip(label: l.projectLead, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
