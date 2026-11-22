import 'package:flutter/material.dart';

import '../core/app_text.dart';

/// Titre + sous-titre en haut des écrans de connexion / inscription.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.headlineLarge),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: AppText.body(context, size: 15)),
      ],
    );
  }
}
