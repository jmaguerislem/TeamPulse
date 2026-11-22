import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/settings_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/option_tile.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _languages = ['Français', 'English'];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsState>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.languageItem,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: _languages
              .map(
                (name) => OptionTile(
                  label: name,
                  icon: Icons.language_rounded,
                  selected: s.language == name,
                  onTap: () => context.read<SettingsState>().setLanguage(name),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
