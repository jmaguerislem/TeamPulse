import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../core/settings_state.dart';
import '../../../widgets/app_bottom_nav.dart';
import '../../more/more_screen.dart';
import '../../projects/list/projects_screen.dart';
import '../../tasks/list/tasks_screen.dart';
import '../../team/list/team_screen.dart';
import '../home/dashboard_screen.dart';

/// Coque de l'application : les 5 onglets + la barre de navigation.
/// `IndexedStack` garde l'état (filtres, défilement) quand on change d'onglet.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    DashboardScreen(),
    ProjectsScreen(),
    TasksScreen(),
    TeamScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final prefs = context.watch<SettingsState>();
    final unread = state.unreadCountFor(
      overdue: prefs.notifOverdue,
      reminder: prefs.notifReminder,
      assignment: prefs.notifAssignment,
    );

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        moreBadge: unread,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
