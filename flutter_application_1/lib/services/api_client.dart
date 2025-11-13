import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiClient {
  static String get _baseUrl => ApiConfig.baseUrl;
  final http.Client _client = http.Client();

  /// Retorna o token armazenado localmente, se existir
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Envia requisição GET autenticada
  Future<Map<String, dynamic>> get(String path) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl$path');

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _handleResponse(response);
  }

  /// Envia requisição POST autenticada
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl$path');

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// Envia requisição PUT autenticada
  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl$path');

    final response = await _client.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// Envia requisição DELETE autenticada
  Future<Map<String, dynamic>> delete(String path) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl$path');

    final response = await _client.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _handleResponse(response);
  }

  /// Interpreta a resposta HTTP e retorna em formato uniforme
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        data = {'raw': response.body};
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return {'success': true, 'status': statusCode, 'data': data};
    } else {
      return {
        'success': false,
        'status': statusCode,
        'message': data['message'] ?? 'Erro na requisição.',
        'data': data
      };
    }
  }

  void dispose() {
    _client.close();
  }
}
