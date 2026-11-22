import 'api_client.dart';

/// Utilisateur connecté, tel que renvoyé par le serveur.
class Account {
  final String id;
  final String fullName;
  final String email;
  final String workspaceCode;

  const Account({
    required this.id,
    required this.fullName,
    required this.email,
    required this.workspaceCode,
  });

  factory Account.fromJson(Map<String, dynamic> j) => Account(
    id: j['userId'] as String,
    fullName: j['fullName'] as String,
    email: j['email'] as String,
    workspaceCode: j['workspaceCode'] as String,
  );
}

enum AuthError {
  accountExists,
  accountNotFound,
  emailInUse,
  wrongOldPassword,
  wrongCredentials,
  workspaceNotFound,
  network,
  server,
}

/// Comptes gérés par le serveur (Spring Boot + PostgreSQL).
class AuthService {
  /// Utilisateur actuellement connecté (null si déconnecté).
  static Account? current;

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  }

  /// Traduit une erreur du serveur en erreur d'application.
  static AuthError _map(
    ApiException e, {
    AuthError? on401,
    AuthError? on403,
    AuthError? on409,
  }) {
    if (e.isNetwork) return AuthError.network;
    switch (e.status) {
      case 401:
        return on401 ?? AuthError.wrongCredentials;
      case 403:
        return on403 ?? AuthError.server;
      case 404:
        return AuthError.workspaceNotFound;
      case 409:
        return on409 ?? AuthError.accountExists;
      default:
        return AuthError.server;
    }
  }

  /// Enregistre le jeton et l'utilisateur renvoyés par le serveur.
  static Future<void> _startSession(Map<String, dynamic> data) async {
    await ApiClient.setToken(data['token'] as String);
    current = Account.fromJson(data);
  }

  static Future<AuthError?> register({
    required String fullName,
    required String email,
    required String password,
    String? workspaceCode,
  }) async {
    try {
      final data = await ApiClient.post('/api/auth/register', {
        'fullName': fullName.trim(),
        'email': email.trim(),
        'password': password,
        if (workspaceCode != null && workspaceCode.trim().isNotEmpty)
          'workspaceCode': workspaceCode.trim(),
      });
      await _startSession(data as Map<String, dynamic>);
      return null;
    } on ApiException catch (e) {
      return _map(e, on409: AuthError.accountExists);
    }
  }

  static Future<AuthError?> login(String email, String password) async {
    try {
      final data = await ApiClient.post('/api/auth/login', {
        'email': email.trim(),
        'password': password,
      });
      await _startSession(data as Map<String, dynamic>);
      return null;
    } on ApiException catch (e) {
      return _map(e);
    }
  }

  /// Au démarrage : le jeton enregistré est-il encore valable ?
  static Future<bool> restoreSession() async {
    await ApiClient.loadToken();
    if (ApiClient.token == null) return false;
    try {
      final data = await ApiClient.get('/api/me');
      await _startSession(data as Map<String, dynamic>);
      return true;
    } on ApiException catch (e) {
      if (e.status == 401) await ApiClient.setToken(null); // jeton expiré
      return false;
    }
  }

  static Future<void> logout() async {
    await ApiClient.setToken(null);
    current = null;
  }

  static Future<AuthError?> updateProfile({
    required String newName,
    required String newEmail,
  }) async {
    try {
      final data = await ApiClient.put('/api/me', {
        'fullName': newName.trim(),
        'email': newEmail.trim(),
      });
      await _startSession(data as Map<String, dynamic>);
      return null;
    } on ApiException catch (e) {
      return _map(e, on409: AuthError.emailInUse);
    }
  }

  static Future<AuthError?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await ApiClient.put('/api/me/password', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      return null;
    } on ApiException catch (e) {
      return _map(e, on403: AuthError.wrongOldPassword);
    }
  }
}
