import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/member_avatar.dart';

/// Onglet « Membres » : ceux qui ont au moins une tâche dans ce projet.
class ProjectMembersTab extends StatelessWidget {
  final Project project;
  const ProjectMembersTab({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final ids = s
        .tasksOf(project.id)
        .map((t) => t.assignee)
        .whereType<String>()
        .toSet();
    final members = s.members.where((m) => ids.contains(m.id)).toList();

    if (members.isEmpty) {
      return Text(l.noMemberAssigned, style: AppText.body(context));
    }

    return Column(
      children: members
          .map(
            (m) => AppCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              radius: 18,
              child: Row(
                children: [
                  MemberAvatar(member: m, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: AppText.title(context)),
                        Text(
                          m.isLead ? l.projectLead : m.role,
                          style: AppText.body(context, size: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
