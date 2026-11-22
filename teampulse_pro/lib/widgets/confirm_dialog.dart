import 'package:flutter/material.dart';

import '../core/app_palette.dart';
import '../l10n/app_localizations.dart';

/// Boîte de confirmation avant une action destructive.
/// Retourne `true` si l'utilisateur confirme.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  final l = AppLocalizations.of(context)!;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: ctx.palette.coralInk),
          ),
        ),
      ],
    ),
  );
  return ok == true;
}

/// Message « supprimé » avec bouton Annuler (permet de revenir en arrière).
///
/// On reçoit le `ScaffoldMessengerState` (et non un `BuildContext`) car
/// l'écran qui supprime est souvent fermé juste avant d'afficher le message.
void showUndoSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  required String undoLabel,
  required VoidCallback onUndo,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(label: undoLabel, onPressed: onUndo),
      ),
    );
}
