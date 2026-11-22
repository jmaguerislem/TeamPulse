# TeamPulse Pro

> **Vos projets, en rythme.** Alertes de retard avant qu'il ne soit trop tard.

TeamPulse Pro est une application mobile de **gestion de projets et de tâches en équipe**. Elle permet à une équipe de planifier ses projets, d'assigner des tâches à ses membres, de suivre l'avancement sur un tableau Kanban ou un calendrier, de recevoir des alertes de retard et de produire des rapports PDF.

Le projet est composé de deux parties qui communiquent par une API REST :

| Dossier | Rôle | Technologies |
| --- | --- | --- |
| [`teampulse-api/`](teampulse-api) | Serveur (back-end) | Java 21, Spring Boot 4, Spring Security, JWT, JPA/Hibernate, PostgreSQL |
| [`teampulse_pro/`](teampulse_pro) | Application (front-end) | Flutter / Dart, Provider, SQLite local, PDF |

---

## 1. Concept : équipes et espaces de travail

Le projet repose sur la notion d'**espace de travail** (*workspace*), qui représente une équipe.

- **Créer une équipe** : à l'inscription, si aucun code d'équipe n'est saisi, un nouvel espace est créé avec un **code unique** généré automatiquement. Le créateur devient le **chef de projet** de l'équipe.
- **Rejoindre une équipe** : si l'utilisateur saisit le code d'une équipe existante à l'inscription, il rejoint cet espace en tant que simple membre.
- **Partager le code** : le code d'équipe est affiché dans l'écran Profil, avec un bouton pour le copier et l'envoyer aux collègues.
- **Isolation des données** : tous les projets, tâches, membres et pièces jointes appartiennent à un espace. Chaque requête est filtrée par l'espace de l'utilisateur connecté : une équipe ne voit jamais les données d'une autre.

---

## 2. Fonctionnalités

### Authentification et profil

- Inscription (nom, e-mail, mot de passe d'au moins 8 caractères, code d'équipe optionnel) et connexion
- **Reconnexion automatique** au lancement si le jeton enregistré est encore valide (30 jours par défaut)
- Modification du nom et de l'e-mail, changement de mot de passe (avec vérification de l'ancien)
- Déconnexion

### Projets

- Création, modification et suppression, avec nom, description, date de début et échéance
- Trois statuts : **En cours**, **Terminé**, **En pause**
- Contrôle côté serveur : l'échéance ne peut pas précéder la date de début
- Barre de progression par projet (tâches terminées / tâches totales) et détection des projets en retard
- Écran de détails avec onglets **Tâches** et **Membres**
- La suppression d'un projet supprime aussi ses tâches et leurs pièces jointes

### Tâches

- Titre, description, date d'échéance, projet, **priorité** (haute, moyenne, basse)
- Trois statuts : **À faire**, **En cours**, **Terminée** ; la date de fin est enregistrée automatiquement quand une tâche passe à « Terminée »
- **Liste** avec recherche par titre, filtres par statut et tri par échéance
- **Tableau Kanban** à trois colonnes : appui long puis glisser-déposer pour changer le statut
- **Calendrier des échéances** : les tâches sont affichées par jour
- **Assignation** à un membre de l'équipe (ou retrait de l'assignation)
- **Pièces jointes** : envoi de fichiers (10 Mo maximum), téléchargement et ouverture sur le téléphone, suppression. Les fichiers sont stockés sur le serveur : toute l'équipe les voit.

### Équipe

- Liste des membres avec leur rôle et leur nombre de tâches
- Ajout d'un membre (nom et rôle) et suppression
- Le chef de projet ne peut pas être supprimé
- À la suppression d'un membre, ses tâches redeviennent « non assignées »

### Alertes et notifications

Les notifications sont **générées automatiquement** à partir des tâches non terminées :

| Type | Condition |
| --- | --- |
| **Retard** | l'échéance est dépassée (affiche le nombre de jours de retard) |
| **Rappel** | l'échéance tombe dans les 2 prochains jours |
| **Affectation** | une tâche est assignée à un membre |

- Un badge sur l'onglet « Plus » affiche le nombre de notifications non lues
- Possibilité de marquer une notification, ou toutes, comme lues
- Dans le profil, l'utilisateur choisit quels types d'alertes il souhaite voir

### Tableau de bord, statistiques et rapports

- **Tableau de bord** : projets en cours et terminés, tâches actives / terminées / en retard, progression globale, alerte de retard et prochaines échéances
- **Évolution** : courbe jour par jour des tâches terminées, en cours et en retard, sur 7 ou 30 jours
- **Rapports**, globaux ou par projet : nombre total de tâches, tâches terminées, tâches en retard, **temps moyen de résolution** et **taux de réussite**
- **Export PDF** du rapport, avec partage via Android (Drive, e-mail, etc.)

### Personnalisation

- Interface en **français et en anglais**
- Thème **clair, sombre ou automatique** (suit le système)
- Les préférences sont conservées sur l'appareil

### Travail d'équipe en quasi temps réel

- L'application recharge membres, projets et tâches **toutes les 30 secondes** pour afficher les changements des collègues
- À la suppression d'un élément, un message **« Annuler »** laisse quelques secondes pour revenir en arrière avant que la suppression soit envoyée au serveur
- Hors connexion, l'application garde ce qui est déjà affiché

---

## 3. Architecture

```
┌──────────────────────────┐        HTTP / JSON         ┌───────────────────────────┐
│  Application Flutter     │  ───────────────────────►  │  API Spring Boot          │
│  (Android, iOS, web...)  │   Authorization: Bearer    │  (port 8081)              │
│                          │  ◄───────────────────────  │                           │
│  Provider (état)         │                            │  Spring Security + JWT    │
│  SQLite (jeton, réglages)│                            │  JPA / Hibernate          │
└──────────────────────────┘                            └──────────┬────────────────┘
                                                                   │
                                                  ┌────────────────┴───────────────┐
                                                  │  PostgreSQL      dossier uploads/│
                                                  │  (données)       (pièces jointes)│
                                                  └─────────────────────────────────┘
```

### Back-end (`teampulse-api`)

Organisation du code par fonctionnalité, dans `com.teampulse.api` :

| Package | Contenu |
| --- | --- |
| `auth` | inscription, connexion, profil, changement de mot de passe |
| `user` | entité `AppUser` et son dépôt |
| `workspace` | entité `Workspace` (le code d'équipe) |
| `member` | membres de l'équipe |
| `project` | projets et leurs statuts |
| `task` | tâches, priorités et statuts |
| `attachment` | pièces jointes et stockage des fichiers sur le disque |
| `security` | filtre JWT, génération des jetons, configuration Spring Security |
| `common` | gestion des erreurs |

**Modèle de données** (tables PostgreSQL créées automatiquement par Hibernate) :

| Table | Champs principaux |
| --- | --- |
| `workspaces` | `id`, `code` (unique) |
| `users` | `id`, `fullName`, `email` (unique), `passwordHash`, `workspace_id` |
| `members` | `id`, `name`, `member_role`, `is_lead`, `workspace_id` |
| `projects` | `id`, `name`, `description`, `startDate`, `deadline`, `status`, `workspace_id` |
| `tasks` | `id`, `title`, `description`, `dueDate`, `priority`, `status`, `createdAt`, `completedAt`, `project_id`, `assignee_id`, `workspace_id` |
| `attachments` | `id`, `fileName`, `contentType`, `size`, `storedName`, `createdAt`, `task_id`, `workspace_id` |

Les identifiants sont des UUID.

### Front-end (`teampulse_pro`)

```
lib/
├── main.dart            point d'entrée, reconnexion automatique
├── core/                client HTTP, états (AppState, SettingsState), services, thème
├── models/              Project, Task, Member, Attachment, notifications
├── l10n/                traductions françaises et anglaises (.arb)
├── screens/
│   ├── auth/            accueil, connexion, inscription
│   ├── dashboard/       tableau de bord et coque de navigation (5 onglets)
│   ├── projects/        liste, création, détails
│   ├── tasks/           liste, Kanban, calendrier, création, détails, assignation
│   ├── team/            liste et ajout de membres
│   ├── notifications/   centre de notifications, évolution, rapports
│   ├── profile/         profil, mot de passe, thème, langue, préférences, aide
│   └── more/            onglet « Plus »
└── widgets/             composants réutilisables
```

La navigation principale comporte **5 onglets** : Tableau de bord, Projets, Tâches, Équipe et Plus. L'état est géré avec **Provider** (`AppState` pour les données, `SettingsState` pour les préférences).

---

## 4. Sécurité

- **Mots de passe** : jamais stockés en clair, hachés avec **BCrypt**
- **Authentification sans session** : l'API est *stateless* ; chaque requête porte un **jeton JWT** signé (HMAC) dans l'en-tête `Authorization: Bearer ...`, valable 30 jours
- **Routes protégées** : toutes les routes exigent un jeton valide, sauf `/api/auth/**` ; sinon l'API répond `401`
- **Validation** des entrées (e-mail valide, mot de passe de 8 caractères minimum, champs obligatoires)
- **Cloisonnement des équipes** : chaque accès à un projet, une tâche, un membre ou un fichier vérifie qu'il appartient à l'espace de l'utilisateur
- **Fichiers** : stockés sous un nom aléatoire (UUID) et jamais sous leur nom d'origine ; taille limitée à 10 Mo
- **Secrets hors du dépôt** : le mot de passe de la base et la clé JWT sont dans `application.properties`, qui n'est pas publié

---

## 5. API REST

Toutes les routes demandent un jeton JWT, sauf l'authentification.

| Ressource | Routes |
| --- | --- |
| Authentification | `POST /api/auth/register`, `POST /api/auth/login` |
| Profil | `GET /api/me`, `PUT /api/me`, `PUT /api/me/password` |
| Projets | `GET /api/projects`, `POST /api/projects`, `PUT /api/projects/{id}`, `DELETE /api/projects/{id}` |
| Tâches | `GET /api/tasks` (filtre optionnel `?projectId=`), `POST /api/tasks`, `PUT /api/tasks/{id}`, `PATCH /api/tasks/{id}/status`, `PATCH /api/tasks/{id}/assignee`, `DELETE /api/tasks/{id}` |
| Membres | `GET /api/members`, `POST /api/members`, `DELETE /api/members/{id}` |
| Pièces jointes | `GET /api/tasks/{taskId}/attachments`, `POST /api/tasks/{taskId}/attachments`, `GET /api/attachments/{id}/download`, `DELETE /api/attachments/{id}` |

Les erreurs métier renvoient un code HTTP et un message court, par exemple : `email_taken` (409), `bad_credentials` (401), `workspace_not_found` (404), `deadline_before_start` (400), `lead_cannot_be_removed` (409), `project_not_found`, `task_not_found`, `member_not_found` (404).

---

## 6. Installation

### Prérequis

- JDK 21
- PostgreSQL
- Flutter SDK (Dart `^3.13.5`)
- Un émulateur Android ou un téléphone

### 6.1 Base de données

Créer la base `teampulse` (l'exemple de configuration utilise le port `5433`) :

```sql
CREATE DATABASE teampulse;
```

Les tables sont créées automatiquement au premier démarrage (`spring.jpa.hibernate.ddl-auto=update`).

### 6.2 API

```bash
cd teampulse-api
```

Le fichier `application.properties` contient des secrets : il **n'est pas publié**. Crée-le à partir de l'exemple :

```bash
# Linux / macOS
cp src/main/resources/application-example.properties src/main/resources/application.properties

# Windows (PowerShell)
Copy-Item src/main/resources/application-example.properties src/main/resources/application.properties
```

Modifie ensuite `application.properties` :

| Propriété | À renseigner |
| --- | --- |
| `spring.datasource.url` | l'adresse de ta base (port inclus) |
| `spring.datasource.username` / `password` | tes identifiants PostgreSQL |
| `app.jwt.secret` | une longue phrase secrète d'**au moins 32 caractères** |
| `app.jwt.expiration-days` | durée de validité des jetons (30 par défaut) |
| `app.upload-dir` | dossier des pièces jointes (`uploads` par défaut) |

Lance l'API :

```bash
./mvnw spring-boot:run          # Windows : .\mvnw.cmd spring-boot:run
```

Elle écoute sur `http://localhost:8081`.

### 6.3 Application Flutter

```bash
cd teampulse_pro
flutter pub get
flutter run
```

L'adresse de l'API est définie dans `lib/core/api_client.dart` :

```dart
static const String baseUrl = 'http://10.0.2.2:8081';
```

- `10.0.2.2` correspond au `localhost` de ton PC vu depuis l'**émulateur Android**.
- Sur un **vrai téléphone**, remplace-la par l'adresse IP de ton PC (par exemple `http://192.168.1.20:8081`). Le PC et le téléphone doivent être sur le même réseau.

---

## 7. Dépendances principales

**Back-end** : Spring Web MVC, Spring Data JPA, Spring Security, Bean Validation, PostgreSQL, JJWT.

**Front-end** : `provider` (état), `http` (réseau), `sqflite` (stockage local), `intl` et `flutter_localizations` (traductions), `google_fonts`, `pdf` et `printing` (rapports PDF), `file_picker`, `path_provider` et `open_filex` (pièces jointes).

---

## 8. Ne jamais publier

Ces fichiers sont déjà exclus par les `.gitignore` :

- `teampulse-api/src/main/resources/application.properties` (mot de passe de la base et clé JWT)
- `teampulse-api/uploads/` (fichiers des utilisateurs)
- `key.properties`, `*.jks`, `*.keystore` et `android/local.properties` côté Flutter

Si un secret a été publié par erreur, change-le immédiatement : le supprimer dans un nouveau commit ne suffit pas, il reste dans l'historique Git.

---

## Auteurs

JMAGUER ISLEM