import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._();
  ApiService._();
  factory ApiService() => _instance;

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── GET ─────────────────────────────────────────────────────────────────────

  Future<dynamic> get(String path) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    try {
      final response = await _client.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Sunucuya bağlanılamadı. Backend çalışıyor mu?');
    }
  }

  // ── POST ─────────────────────────────────────────────────────────────────────

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    try {
      final response = await _client
          .post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Sunucuya bağlanılamadı.');
    }
  }

  // ── PATCH ─────────────────────────────────────────────────────────────────────

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    try {
      final response = await _client
          .patch(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Sunucuya bağlanılamadı.');
    }
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────────

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    try {
      final response = await _client.delete(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 204) return null;
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Sunucuya bağlanılamadı.');
    }
  }

  // ── Response handler ─────────────────────────────────────────────────────────

  dynamic _handleResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return null;
      return jsonDecode(body);
    }
    String message;
    try {
      final json = jsonDecode(body);
      message = json['detail'] as String? ?? 'Bir hata oluştu.';
    } catch (_) {
      message = 'Sunucu hatası (${response.statusCode})';
    }
    throw ApiException(message, statusCode: response.statusCode);
  }
}
