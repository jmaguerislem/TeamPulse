import 'package:flutter/material.dart';

import '../core/app_tokens.dart';

/// Grand titre des écrans principaux (onglets).
class ScreenTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const ScreenTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.page,
        AppSpace.l,
        AppSpace.s,
        AppSpace.m,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(text, style: Theme.of(context).textTheme.headlineLarge),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
