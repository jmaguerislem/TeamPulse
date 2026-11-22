import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_palette.dart';
import '../../../core/app_text.dart';
import '../../../core/project_ui.dart';
import '../../../models/models.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_progress_bar.dart';
import '../../../widgets/status_chip.dart';

/// Carte du haut de l'écran détail : nom, statut, pourcentage, dates.
class ProjectHeaderCard extends StatelessWidget {
  final Project project;
  final StatusInfo status;
  final double progress;
  const ProjectHeaderCard({
    super.key,
    required this.project,
    required this.status,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      padding: const EdgeInsets.all(18),
      radius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.folder_outlined, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: AppText.heading(context, size: 19),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: StatusChip(
                        label: status.label,
                        color: status.color,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: AppText.number(context, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppProgressBar(value: progress, color: status.color),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.event_outlined, size: 16, color: p.soft),
              const SizedBox(width: 6),
              Text(
                '${fmtDate(project.startDate)}  →  ${fmtDate(project.deadline)}',
                style: AppText.body(context, size: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
