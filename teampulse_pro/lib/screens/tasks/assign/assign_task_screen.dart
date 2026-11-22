import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../core/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/form_label.dart';
import '../../../widgets/primary_button.dart';
import 'member_option_tile.dart';

/// Affectation d'une tâche à un membre de l'équipe.
class AssignTaskScreen extends StatefulWidget {
  final String taskId;
  const AssignTaskScreen({super.key, required this.taskId});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = context.read<AppState>().taskById(widget.taskId)?.assignee;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final task = s.taskById(widget.taskId);
    if (task == null) return const Scaffold(body: SizedBox());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.assignTask,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ContentWidth(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.page,
            AppSpace.s,
            AppSpace.page,
            AppSpace.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormLabel(l.taskLabel, top: 0),
              AppCard(
                radius: 18,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(task.title, style: AppText.title(context)),
                ),
              ),
              FormLabel(l.memberLabel),
              Expanded(
                child: s.members.isEmpty
                    ? EmptyState(
                        icon: Icons.groups_outlined,
                        title: l.noMembersYet,
                        message: l.addMembersFirst,
                      )
                    : ListView.separated(
                        itemCount: s.members.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final m = s.members[i];
                          return MemberOptionTile(
                            member: m,
                            selected: _selected == m.id,
                            onTap: () => setState(() => _selected = m.id),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: l.assign,
                onPressed: s.members.isEmpty
                    ? null
                    : () {
                        context
                            .read<AppState>()
                            .assignTask(widget.taskId, _selected);
                        Navigator.pop(context);
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
