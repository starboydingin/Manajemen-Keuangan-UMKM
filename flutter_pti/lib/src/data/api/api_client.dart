import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({required this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: _encodeQuery(query));
    final response = await _client.get(uri, headers: _withDefaults(headers));
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _withDefaults(headers),
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl$path'),
      headers: _withDefaults(headers),
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Map<String, dynamic>? _encodeQuery(Map<String, dynamic>? query) {
    if (query == null) return null;
    final mapped = <String, String>{};
    query.forEach((key, value) {
      if (value == null) return;
      mapped[key] = '$value';
    });
    return mapped;
  }

  Map<String, String> _withDefaults(Map<String, String>? headers) {
    return {
      'Content-Type': 'application/json',
      ...?headers,
    };
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    final message = decoded['message']?.toString() ?? 'Terjadi kesalahan tak terduga';
    throw ApiException(message, statusCode: response.statusCode, details: decoded['details']);
  }

  void dispose() {
    _client.close();
  }
}
