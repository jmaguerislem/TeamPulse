import 'package:flutter/material.dart';

import '../core/project_ui.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import 'status_chip.dart';

class PriorityChip extends StatelessWidget {
  final TaskPriority priority;
  const PriorityChip({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final info = priorityInfo(priority, AppLocalizations.of(context)!);
    return StatusChip(label: info.label, color: info.color);
  }
}
