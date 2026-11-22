import 'package:flutter/material.dart';

import '../../../core/app_palette.dart';
import '../../../core/app_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/member_avatar.dart';
import '../../../widgets/status_chip.dart';
import '../../../core/app_colors.dart';

/// Ligne d'un membre : avatar, nom, rôle · nombre de tâches, badge ou retrait.
class MemberTile extends StatelessWidget {
  final Member member;
  final int taskCount;
  final VoidCallback onRemove;

  /// Seule la cheffe de projet peut retirer un membre (et seulement tant
  /// qu'il n'a pas créé son compte).
  final bool canRemove;

  const MemberTile({
    super.key,
    required this.member,
    required this.taskCount,
    required this.onRemove,
    this.canRemove = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final subtitle = member.role.isEmpty
        ? l.memberTasks(taskCount)
        : l.memberRoleTasks(member.role, taskCount);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        children: [
          MemberAvatar(member: member),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: AppText.title(context, size: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppText.body(context, size: 13)),
                if (member.email.isNotEmpty)
                  Text(
                    member.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(context, size: 12),
                  ),
                if (!member.isLead && !member.joined)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: StatusChip(
                      label: l.memberPending,
                      color: AppColors.amber,
                      icon: Icons.schedule_rounded,
                    ),
                  ),
              ],
            ),
          ),
          if (member.isLead)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: StatusChip(label: l.projectLead, color: AppColors.primary),
            )
          else if (canRemove && !member.joined)
            IconButton(
              tooltip: l.removeMemberTooltip(member.name),
              icon: Icon(Icons.close_rounded, color: p.soft),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
