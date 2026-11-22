import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/settings_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/option_tile.dart';

/// Choix du thème : clair, sombre ou suivre le système.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsState>();
    final l = AppLocalizations.of(context)!;
    final modes = [
      (ThemeMode.light, l.themeLight, Icons.light_mode_outlined),
      (ThemeMode.dark, l.themeDark, Icons.dark_mode_outlined),
      (ThemeMode.system, l.themeSystem, Icons.phone_android_rounded),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.appearanceItem,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: modes.map((m) {
            final (mode, label, icon) = m;
            return OptionTile(
              label: label,
              icon: icon,
              selected: s.themeMode == mode,
              onTap: () => context.read<SettingsState>().setThemeMode(mode),
            );
          }).toList(),
        ),
      ),
    );
  }
}
