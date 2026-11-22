import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_palette.dart';
import '../../../core/app_text.dart';
import '../../../core/auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/icon_tile.dart';

/// Code d'équipe à partager pour inviter des collègues à rejoindre l'équipe.
class TeamCodeCard extends StatelessWidget {
  const TeamCodeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final code = AuthService.current?.workspaceCode ?? '';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      radius: 20,
      padding: const EdgeInsets.fromLTRB(16, 14, 6, 14),
      child: Row(
        children: [
          const IconTile(
            icon: Icons.group_add_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.teamCodeTitle, style: AppText.body(context, size: 13)),
                Text(
                  code,
                  style: AppText.number(context, size: 22, color: p.primaryInk),
                ),
                Text(l.teamCodeShare, style: AppText.body(context, size: 12)),
              ],
            ),
          ),
          IconButton(
            tooltip: l.copyCode,
            icon: const Icon(Icons.copy_rounded),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await Clipboard.setData(ClipboardData(text: code));
              messenger.showSnackBar(SnackBar(content: Text(l.codeCopied)));
            },
          ),
        ],
      ),
    );
  }
}
