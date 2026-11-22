# TeamPulse Pro

Gestion intelligente de projets : projets, tâches, échéances, équipe, avec des
indicateurs d'avancement et des **alertes de retard**.

## Lancer l'application

```bash
flutter pub get
flutter run
```

Les traductions (`lib/l10n/*.arb`) sont régénérées automatiquement au lancement.

## Structure du code

Chaque interface a son propre dossier : un fichier `*_screen.dart` (l'écran)
et à côté les fichiers de ses composants (cartes, formulaires, graphiques…).

```
lib/
├── main.dart                      Point d'entrée, thèmes, langue
├── core/                          Logique et design system
│   ├── app_colors.dart            Couleurs de marque
│   ├── app_palette.dart           Couleurs clair / sombre  (context.palette)
│   ├── app_tokens.dart            Espacements, rayons, durées
│   ├── app_text.dart              Styles de texte (Outfit + DM Sans)
│   ├── app_theme.dart             Thèmes clair et sombre
│   ├── app_state.dart             Projets, tâches, équipe, notifications
│   ├── settings_state.dart        Thème, langue, préférences
│   ├── auth_service.dart          Comptes (en mémoire pour l'instant)
│   └── user_session.dart          Utilisateur connecté
├── models/                        Project, Task, Member, notifications
├── l10n/                          Français / English
├── widgets/                       Composants partagés (AppCard, StatusChip…)
└── screens/
    ├── auth/        welcome/  login/  signup/
    ├── dashboard/   shell/  home/
    ├── projects/    list/  create/  details/
    ├── tasks/       list/  create/  details/  assign/  kanban/  deadlines/
    ├── team/        list/  add/
    ├── notifications/  center/  progress/  reports/
    ├── profile/     overview/  edit/  change_password/  language/
    │                appearance/  notification_prefs/  help/
    └── more/
```

## Design

- Couleurs : violet pulse `#5B4CFF`, menthe (terminé), ambre (en attente),
  **corail réservé aux retards et alertes**.
- Thème clair et sombre : on n'utilise jamais `Colors.white` ni `AppColors.navy`
  pour un fond ou un texte, mais `context.palette` (`card`, `ink`, `soft`…).
- Un statut n'est jamais indiqué par la couleur seule (texte + icône).
- Zones tactiles d'au moins 48 px, libellés pour les lecteurs d'écran,
  chiffres alignés (`tabularFigures`), animations coupées si le système le demande.

## Limites actuelles / prochaines étapes

- Les données (comptes, projets, tâches, équipe, réglages, pièces jointes) sont
  enregistrées dans une **base SQLite locale** (`core/local_db.dart`) et conservées
  après la fermeture de l'application. Chaque compte a ses propres données, mais
  elles restent sur **l'appareil** : pas de partage entre utilisateurs ni entre
  téléphones, et elles sont perdues si l'application est désinstallée.
- Les pièces jointes sont copiées dans le dossier de l'application sur le
  téléphone : elles ne sont pas synchronisées non plus.
- Prévu : API + PostgreSQL pour partager les données et synchroniser plusieurs
  appareils.
- Les mots de passe sont stockés avec un hachage SHA-256 sans « sel », ce qui
  suffit pour un projet d'école. Avec le backend, utiliser bcrypt ou argon2.
