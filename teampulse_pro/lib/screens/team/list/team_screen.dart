import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/gradient_fab.dart';
import '../../../widgets/screen_title.dart';
import '../add/add_member_screen.dart';
import 'member_tile.dart';

/// Onglet « Équipe » : membres, rôle, charge de travail.
class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  void _add(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddMemberScreen()),
  );

  Future<void> _remove(BuildContext context, Member m) async {
    final l = AppLocalizations.of(context)!;
    final state = context.read<AppState>();
    final ok = await showConfirmDialog(
      context,
      title: l.removeMemberTitle,
      body: l.removeMemberBody(m.name),
      confirmLabel: l.remove,
    );
    if (!ok || !context.mounted) return;

    final removed = state.removeMember(m.id);
    if (removed == null) return;
    showUndoSnackBar(
      ScaffoldMessenger.of(context),
      message: l.memberRemovedMsg(m.name),
      undoLabel: l.undo,
      onUndo: () => state.restoreMember(removed.member, removed.taskIds),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final members = s.members;

    return SafeArea(
      child: ContentWidth(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenTitle(l.navTeam),
                Expanded(
                  child: members.isEmpty
                      ? EmptyState(
                          icon: Icons.groups_outlined,
                          title: l.noMembersYet,
                          message: l.noMembersHint,
                          actionLabel: s.isLead ? l.newMember : null,
                          onAction: s.isLead ? () => _add(context) : null,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.page,
                            AppSpace.xs,
                            AppSpace.page,
                            AppSpace.navClearance + 20,
                          ),
                          itemCount: members.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpace.m),
                          itemBuilder: (_, i) => MemberTile(
                            member: members[i],
                            taskCount: s.tasksOfMember(members[i].id),
                            canRemove: s.isLead,
                            onRemove: () => _remove(context, members[i]),
                          ),
                        ),
                ),
              ],
            ),
            if (s.isLead)
              Positioned(
                right: AppSpace.page,
                bottom: AppSpace.fabBottom,
                child: GradientFab(
                  tooltip: l.newMember,
                  onPressed: () => _add(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
