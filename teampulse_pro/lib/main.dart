import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_state.dart';
import 'core/app_theme.dart';
import 'core/auth_service.dart';
import 'core/local_db.dart';
import 'core/settings_state.dart';
import 'core/user_session.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth/welcome/welcome_screen.dart';
import 'screens/dashboard/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDb.init();

  final appState = AppState();
  final settings = SettingsState();
  await settings.load();

  // Reconnexion automatique si le jeton enregistré est encore valable.
  Widget home = const WelcomeScreen();
  if (await AuthService.restoreSession()) {
    final account = AuthService.current!;
    UserSession.fullName = account.fullName;
    UserSession.email = account.email;
    await appState.start();
    home = const MainShell();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: TeamPulseApp(home: home),
    ),
  );
}

class TeamPulseApp extends StatelessWidget {
  final Widget home;
  const TeamPulseApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsState>();
    return MaterialApp(
      title: 'TeamPulse Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }
}
