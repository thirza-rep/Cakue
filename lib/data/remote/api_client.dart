import 'dart:convert';
import 'package:http/http.dart' as http;

/// Centralized HTTP client untuk komunikasi ke Cakue Backend API
class ApiClient {
  static const String _baseUrl = '/api'; // Nginx proxy handles routing

  final http.Client _client;

  ApiClient([http.Client? client]) : _client = client ?? http.Client();

  // ── GET ──────────────────────────────────────────────────────────────
  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = _buildUri(path, queryParams);
    final response = await _client.get(uri, headers: _headers());
    return _handleResponse(response);
  }

  // ── POST ─────────────────────────────────────────────────────────────
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = _buildUri(path);
    final response = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  // ── PUT ──────────────────────────────────────────────────────────────
  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final uri = _buildUri(path);
    final response = await _client.put(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  // ── DELETE ───────────────────────────────────────────────────────────
  Future<dynamic> delete(String path) async {
    final uri = _buildUri(path);
    final response = await _client.delete(uri, headers: _headers());
    return _handleResponse(response);
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final fullPath = '$_baseUrl$path';
    // Use relative URI so it works with both localhost and docker nginx proxy
    if (queryParams != null && queryParams.isNotEmpty) {
      return Uri(path: fullPath, queryParameters: queryParams);
    }
    return Uri(path: fullPath);
  }

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  dynamic _handleResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return null;
      return jsonDecode(body);
    }
    final errBody = body.isNotEmpty ? jsonDecode(body) : {};
    throw ApiException(
      statusCode: response.statusCode,
      message: (errBody is Map ? errBody['error'] : null) ?? 'API Error ${response.statusCode}',
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
