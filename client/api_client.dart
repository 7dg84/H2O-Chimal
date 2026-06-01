import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Cliente ligero para la API descrita en `design/api.md`.
/// Guarda la cookie `auth_token` en `SharedPreferences` y la adjunta
/// a las peticiones autenticadas como header `Cookie: auth_token=...`.
class ApiClient {
  final String baseUrl;
  final http.Client _http;

  ApiClient({required this.baseUrl, http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  static const _tokenKey = 'auth_token';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<String?> _getToken() async {
    final p = await _prefs;
    return p.getString(_tokenKey);
  }

  Future<void> _setToken(String? token) async {
    final p = await _prefs;
    if (token == null) {
      await p.remove(_tokenKey);
    } else {
      await p.setString(_tokenKey, token);
    }
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Cookie'] = 'auth_token=$token';
    }
    return headers;
  }

  // --- Authentication ---
  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/api/auth/register/');
    final res = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Register failed: ${res.statusCode} ${res.body}');
  }

  Future<void> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/api/auth/login/');
    final res = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      // Try to extract auth_token from Set-Cookie header
      final setCookie = res.headers['set-cookie'];
      String? token;
      if (setCookie != null) {
        final match = RegExp(r'auth_token=([^;]+)').firstMatch(setCookie);
        if (match != null) token = match.group(1);
      }
      // Also accept token in body if provided
      if (token == null) {
        try {
          final body = jsonDecode(res.body);
          if (body is Map && body['auth_token'] is String)
            token = body['auth_token'];
        } catch (_) {}
      }
      if (token != null) {
        await _setToken(token);
        return;
      }
      // Some servers may return success but set cookies via different path; if login returned success, keep going
      return;
    }
    throw Exception('Login failed: ${res.statusCode} ${res.body}');
  }

  Future<void> logout() async {
    final uri = Uri.parse('$baseUrl/api/auth/logout/');
    final headers = await _authHeaders();
    final res = await _http.post(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      await _setToken(null);
      return;
    }
    throw Exception('Logout failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> getUser() async {
    final uri = Uri.parse('$baseUrl/api/auth/user/');
    final headers = await _authHeaders();
    final res = await _http.get(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Get user failed: ${res.statusCode} ${res.body}');
  }

  // --- Reports ---
  Future<List<dynamic>> getReports() async {
    final uri = Uri.parse('$baseUrl/api/reports/');
    final headers = await _authHeaders();
    final res = await _http.get(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Get reports failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> getReport(String id) async {
    final uri = Uri.parse('$baseUrl/api/reports/$id/');
    final headers = await _authHeaders();
    final res = await _http.get(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Get report failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> createReport(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/api/reports/');
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';
    final res = await _http.post(uri, headers: headers, body: jsonEncode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Create report failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> updateReport(
    String id,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl/api/reports/$id/');
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';
    final res = await _http.put(uri, headers: headers, body: jsonEncode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Update report failed: ${res.statusCode} ${res.body}');
  }

  Future<void> deleteReport(String id) async {
    final uri = Uri.parse('$baseUrl/api/reports/$id/');
    final headers = await _authHeaders();
    final res = await _http.delete(uri, headers: headers);
    if (res.statusCode == 204) return;
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw Exception('Delete report failed: ${res.statusCode} ${res.body}');
  }

  // --- Media ---
  Future<Map<String, dynamic>> getMediaById(String id) async {
    final uri = Uri.parse('$baseUrl/api/media/$id/');
    final headers = await _authHeaders();
    final res = await _http.get(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Get media failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> uploadMedia(File file, String reportId) async {
    final uri = Uri.parse('$baseUrl/api/media/');
    final token = await _getToken();
    final request = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty)
      request.headers['Cookie'] = 'auth_token=$token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['report'] = reportId;
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Upload media failed: ${res.statusCode} ${res.body}');
  }

  // --- Services ---
  Future<List<dynamic>> getServices() async {
    final uri = Uri.parse('$baseUrl/api/services/');
    final res = await _http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Get services failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> getService(String id) async {
    final uri = Uri.parse('$baseUrl/api/services/$id/');
    final res = await _http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Get service failed: ${res.statusCode} ${res.body}');
  }

  // --- Tramites ---
  Future<List<dynamic>> getTramites() async {
    final uri = Uri.parse('$baseUrl/api/tramites/');
    final headers = await _authHeaders();
    final res = await _http.get(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Get tramites failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> createTramite(String serviceId) async {
    final uri = Uri.parse('$baseUrl/api/tramites/');
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';
    final res = await _http.post(
      uri,
      headers: headers,
      body: jsonEncode({'service': serviceId}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Create tramite failed: ${res.statusCode} ${res.body}');
  }

  Future<void> deleteTramite(String id) async {
    final uri = Uri.parse('$baseUrl/api/tramites/$id/');
    final headers = await _authHeaders();
    final res = await _http.delete(uri, headers: headers);
    if (res.statusCode == 204) return;
    throw Exception('Delete tramite failed: ${res.statusCode} ${res.body}');
  }

  // --- Documents ---
  Future<Map<String, dynamic>> getDocumentById(String id) async {
    final uri = Uri.parse('$baseUrl/api/documents/$id/');
    final headers = await _authHeaders();
    final res = await _http.get(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Get document failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> uploadDocument(
    File file,
    String tramiteId,
    String documentTypeId,
  ) async {
    final uri = Uri.parse('$baseUrl/api/documents/');
    final token = await _getToken();
    final request = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty)
      request.headers['Cookie'] = 'auth_token=$token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['tramite'] = tramiteId;
    request.fields['document_type'] = documentTypeId;
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Upload document failed: ${res.statusCode} ${res.body}');
  }

  Future<void> deleteDocument(String id) async {
    final uri = Uri.parse('$baseUrl/api/documents/$id/');
    final headers = await _authHeaders();
    final res = await _http.delete(uri, headers: headers);
    if (res.statusCode == 204) return;
    throw Exception('Delete document failed: ${res.statusCode} ${res.body}');
  }
}
