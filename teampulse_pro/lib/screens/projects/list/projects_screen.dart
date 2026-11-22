import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/filter_chips_bar.dart';
import '../../../widgets/gradient_fab.dart';
import '../../../widgets/screen_title.dart';
import '../../../widgets/search_field.dart';
import '../create/create_project_screen.dart';
import 'project_card.dart';

/// Onglet « Projets » : recherche + filtres par statut + liste.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  int _filter = 0;
  String _query = '';

  List<Project> _apply(List<Project> all) {
    final q = _query.trim().toLowerCase();
    return all.where((p) {
      final matchesFilter = switch (_filter) {
        1 => p.status == ProjectStatus.inProgress,
        2 => p.status == ProjectStatus.done,
        3 => p.status == ProjectStatus.onHold,
        _ => true,
      };
      return matchesFilter && (q.isEmpty || p.name.toLowerCase().contains(q));
    }).toList();
  }

  void _create() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
  );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final list = _apply(s.projects);

    return SafeArea(
      child: ContentWidth(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenTitle(l.myProjects),
                SearchField(
                  hint: l.searchProjects,
                  onChanged: (v) => setState(() => _query = v),
                ),
                FilterChipsBar(
                  labels: [
                    l.filterAll,
                    l.filterInProgress,
                    l.filterDone,
                    l.filterOnHold,
                  ],
                  selected: _filter,
                  onSelected: (i) => setState(() => _filter = i),
                ),
                const SizedBox(height: AppSpace.m),
                Expanded(
                  child: s.projects.isEmpty
                      ? EmptyState(
                          icon: Icons.folder_open_rounded,
                          title: l.noProjectHere,
                          message: l.noProjectHint,
                          actionLabel: l.createProject,
                          onAction: _create,
                        )
                      : list.isEmpty
                      ? EmptyState(
                          icon: Icons.search_off_rounded,
                          title: l.noResults,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.page,
                            AppSpace.xs,
                            AppSpace.page,
                            AppSpace.navClearance + 20,
                          ),
                          itemCount: list.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpace.m),
                          itemBuilder: (_, i) =>
                              ProjectCard(project: list[i], colorIndex: i),
                        ),
                ),
              ],
            ),
            Positioned(
              right: AppSpace.page,
              bottom: AppSpace.fabBottom,
              child: GradientFab(tooltip: l.createProject, onPressed: _create),
            ),
          ],
        ),
      ),
    );
  }
}
