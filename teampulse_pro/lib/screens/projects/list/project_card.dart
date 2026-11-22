import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../core/project_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_progress_bar.dart';
import '../../../widgets/icon_tile.dart';
import '../../../widgets/status_chip.dart';
import '../details/project_details_screen.dart';

/// Carte d'un projet dans la liste : icône, nom, statut et barre d'avancement.
class ProjectCard extends StatelessWidget {
  final Project project;
  final int colorIndex;
  const ProjectCard({super.key, required this.project, required this.colorIndex});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final info = projectStatusInfo(s, project, l);
    final total = s.tasksOf(project.id).length;
    final done = s.tasksDoneOf(project.id);
    final progress = s.projectProgress(project.id);
    final iconColor = projectIconColors[colorIndex % projectIconColors.length];

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(projectId: project.id),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconTile(icon: Icons.folder_outlined, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.title(context, size: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.tasksProgress(done, total),
                      style: AppText.body(context, size: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(
                label: info.label,
                color: info.color,
                icon: info.color == projectStatusLateColor
                    ? Icons.warning_amber_rounded
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: AppProgressBar(value: progress, color: info.color)),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).round()}%',
                style: AppText.label(context, size: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
