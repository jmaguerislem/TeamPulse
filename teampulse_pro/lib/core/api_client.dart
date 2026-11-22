import 'dart:convert';

import 'package:http/http.dart' as http;

import 'local_db.dart';

/// Erreur renvoyée par le serveur. `status == 0` : le serveur est injoignable.
class ApiException implements Exception {
  final int status;
  final String message;
  const ApiException(this.status, this.message);

  bool get isNetwork => status == 0;

  @override
  String toString() => 'ApiException($status, $message)';
}

/// Petit client HTTP : ajoute l'adresse du serveur et le jeton à chaque appel.
class ApiClient {
  /// 10.0.2.2 = le « localhost » de ton PC vu depuis l'émulateur Android.
  /// Sur un vrai téléphone : l'adresse IP de ton PC (ex. http://192.168.1.20:8081).
  static const String baseUrl = 'http://10.0.2.2:8081';

  static String? token;

  static Future<void> loadToken() async {
    token = await LocalDb.read('token');
  }

  static Future<void> setToken(String? value) async {
    token = value;
    if (value == null) {
      await LocalDb.delete('token');
    } else {
      await LocalDb.write('token', value);
    }
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    ..._authHeaders,
  };

  static Map<String, String> get _authHeaders => {
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Future<dynamic> get(String path) => _send('GET', path);
  static Future<dynamic> post(String path, [Object? body]) =>
      _send('POST', path, body);
  static Future<dynamic> put(String path, [Object? body]) =>
      _send('PUT', path, body);
  static Future<dynamic> patch(String path, [Object? body]) =>
      _send('PATCH', path, body);
  static Future<dynamic> delete(String path) => _send('DELETE', path);

  static Future<dynamic> _send(
    String method,
    String path, [
    Object? body,
  ]) async {
    final uri = Uri.parse('$baseUrl$path');
    final payload = body == null ? null : jsonEncode(body);

    final Future<http.Response> call = switch (method) {
      'GET' => http.get(uri, headers: _headers),
      'POST' => http.post(uri, headers: _headers, body: payload),
      'PUT' => http.put(uri, headers: _headers, body: payload),
      'PATCH' => http.patch(uri, headers: _headers, body: payload),
      _ => http.delete(uri, headers: _headers),
    };

    final http.Response response;
    try {
      response = await call.timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const ApiException(0, 'network');
    }
    return _decode(response);
  }

  /// Envoie un fichier (multipart/form-data, champ « file »).
  static Future<dynamic> upload(
    String path,
    String filePath,
    String fileName,
  ) async {
    final http.Response response;
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
      request.headers.addAll(_authHeaders);
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath, filename: fileName),
      );
      final streamed = await request.send().timeout(
        const Duration(seconds: 60),
      );
      response = await http.Response.fromStream(streamed);
    } catch (_) {
      throw const ApiException(0, 'network');
    }
    return _decode(response);
  }

  /// Télécharge un fichier et retourne son contenu.
  static Future<List<int>> download(String path) async {
    final http.Response response;
    try {
      response = await http
          .get(Uri.parse('$baseUrl$path'), headers: _authHeaders)
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      throw const ApiException(0, 'network');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, 'http_${response.statusCode}');
    }
    return response.bodyBytes;
  }

  static dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.bodyBytes.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw ApiException(response.statusCode, 'http_${response.statusCode}');
  }
}
