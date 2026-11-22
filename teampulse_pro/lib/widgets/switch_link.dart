import 'package:flutter/material.dart';

import '../core/app_palette.dart';
import '../core/app_text.dart';

/// Lien de bas de page : « Pas encore de compte ? **Créer un compte** ».
class SwitchLink extends StatelessWidget {
  final String prefix;
  final String action;
  final VoidCallback onTap;

  const SwitchLink({
    super.key,
    required this.prefix,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: TextButton(
        onPressed: onTap,
        child: Text.rich(
          TextSpan(
            text: prefix,
            style: AppText.body(context, size: 14),
            children: [
              TextSpan(
                text: action,
                style: AppText.title(context, size: 14, color: p.primaryInk),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
