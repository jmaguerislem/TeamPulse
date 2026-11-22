import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_palette.dart';
import '../../../core/app_state.dart';
import '../../../core/app_text.dart';
import '../../../core/project_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/icon_tile.dart';

/// Section « Pièces jointes » de l'écran détail d'une tâche.
/// Les fichiers sont stockés sur le serveur : toute l'équipe les voit.
class TaskAttachments extends StatefulWidget {
  final Task task;
  const TaskAttachments({super.key, required this.task});

  @override
  State<TaskAttachments> createState() => _TaskAttachmentsState();
}

class _TaskAttachmentsState extends State<TaskAttachments> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await context.read<AppState>().loadAttachments(widget.task.id);
    } catch (_) {
      // hors connexion : on garde la liste déjà affichée
    }
  }

  String _size(int bytes) => bytes < 1024 * 1024
      ? '${(bytes / 1024).round()} Ko'
      : '${(bytes / 1024 / 1024).toStringAsFixed(1)} Mo';

  String _message(Object e, AppLocalizations l) {
    if (e is ApiException && e.status == 413) return l.fileTooLarge;
    return apiErrorText(e, l);
  }

  Future<void> _add() async {
    if (_busy) return;
    final l = AppLocalizations.of(context)!;
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await FilePicker.pickFiles();
    if (result.isEmpty) return;
    final picked = result.first;
    if (picked.path == null) return;

    setState(() => _busy = true);
    try {
      await state.uploadAttachment(widget.task.id, picked.path!, picked.name);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_message(e, l))));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _open(Attachment a) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await ApiClient.download(
        '/api/attachments/${a.id}/download',
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${a.id}_${a.name}');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_message(e, l))));
    }
  }

  Future<void> _remove(Attachment a) async {
    final l = AppLocalizations.of(context)!;
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await showConfirmDialog(
      context,
      title: l.deleteAttachmentTitle,
      body: l.deleteAttachmentBody(a.name),
      confirmLabel: l.delete,
    );
    if (!ok) return;
    try {
      await state.deleteAttachment(widget.task.id, a);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_message(e, l))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final task =
        context.watch<AppState>().taskById(widget.task.id) ?? widget.task;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(l.attachments, style: AppText.heading(context, size: 18)),
        const SizedBox(height: 12),
        if (task.attachments.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(l.noAttachments, style: AppText.body(context)),
          ),
        ...task.attachments.map(
          (a) => AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            radius: 18,
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            onTap: () => _open(a),
            child: Row(
              children: [
                const IconTile(
                  icon: Icons.insert_drive_file_outlined,
                  color: AppColors.primary,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.title(context),
                      ),
                      Text(
                        _size(a.size),
                        style: AppText.body(context, size: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l.removeAttachment,
                  icon: Icon(Icons.close_rounded, color: p.soft),
                  onPressed: () => _remove(a),
                ),
              ],
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _busy ? null : _add,
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.attach_file_rounded),
          label: Text(l.addAttachment),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
