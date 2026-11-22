import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_palette.dart';
import '../../../core/app_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/member_avatar.dart';

/// Choix d'un membre dans la liste d'affectation (sélection visible par
/// la bordure ET la coche, pas seulement par la couleur).
class MemberOptionTile extends StatelessWidget {
  final Member member;
  final bool selected;
  final VoidCallback onTap;

  const MemberOptionTile({
    super.key,
    required this.member,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    return Semantics(
      selected: selected,
      child: AppCard(
        onTap: onTap,
        radius: 18,
        padding: const EdgeInsets.all(12),
        color: selected ? AppColors.primary.withValues(alpha: 0.1) : null,
        borderColor: selected ? AppColors.primary : null,
        child: Row(
          children: [
            MemberAvatar(member: member, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: AppText.title(context)),
                  Text(
                    member.isLead ? l.projectLead : member.role,
                    style: AppText.body(context, size: 13),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: p.primaryInk),
          ],
        ),
      ),
    );
  }
}
