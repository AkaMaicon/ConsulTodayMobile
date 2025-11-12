import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// AuthService — handles register/login with the Consultoday API.
///
/// Notes:
/// - Default baseUrl uses 10.0.2.2 for Android emulator to reach host machine.
///   * If you're testing on a real device, replace with your machine IP (e.g. http://192.168.1.10:8080)
///   * If you're using iOS simulator, `http://localhost:8080` works.
class AuthService {
  /// Change this if running on a real device or different environment.
  static const String _baseUrl = 'http://localhost:8080';

  /// Register a new paciente.
  /// Returns map: { 'success': bool, 'status': int?, 'message': String?, 'data': Map? }
  Future<Map<String, dynamic>> register({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
    required String cpf,
  }) async {
    final url = Uri.parse('$_baseUrl/api/pacientes/cadastrar');
    final body = jsonEncode({
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
      'senha': senha,
      'ativo': true,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final status = response.statusCode;
      final responseBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (status == 200 || status == 201) {
        return {'success': true, 'status': status, 'data': responseBody};
      } else if (status == 400 || status == 422) {
        // validation errors from backend often return message or field errors
        String msg = 'Erro ao cadastrar.';
        if (responseBody is Map && responseBody.containsKey('message')) {
          msg = responseBody['message'];
        } else if (responseBody is Map && responseBody.containsKey('errors')) {
          msg = responseBody['errors'].toString();
        } else if (responseBody is String && responseBody.isNotEmpty) {
          msg = responseBody;
        }
        return {'success': false, 'status': status, 'message': msg};
      } else {
        return {
          'success': false,
          'status': status,
          'message':
              'Erro inesperado ao cadastrar (status $status). Verifique o servidor.'
        };
      }
    } catch (e) {
      print('Erro no AuthService.register: $e');
      return {
        'success': false,
        'message':
            'Falha ao conectar ao servidor. Certifique-se que a API está rodando e o endereço está correto.'
      };
    }
  }

  /// Login with email and senha.
  /// Returns map: { 'success': bool, 'status': int?, 'message': String?, 'token': String?, 'data': Map? }
  Future<Map<String, dynamic>> login({
  required String email,
  required String senha,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final body = jsonEncode({
      'email': email,
      'senha': senha,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final status = response.statusCode;
      final responseBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (status == 200) {
        String? token;
        if (responseBody is Map && responseBody.containsKey('token')) {
          token = responseBody['token'];
        } else if (responseBody is Map && responseBody.containsKey('accessToken')) {
          token = responseBody['accessToken'];
        } else if (responseBody is Map && responseBody.containsKey('jwt')) {
          token = responseBody['jwt'];
        } else if (responseBody is String) {
          token = responseBody;
        }

        // ✅ Salva o token no SharedPreferences
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
        }

        return {
          'success': true,
          'status': status,
          'token': token,
          'data': responseBody
        };
      } else if (status == 401 || status == 400) {
        String msg = 'Email ou senha inválidos.';
        if (responseBody is Map && responseBody.containsKey('message')) {
          msg = responseBody['message'];
        }
        return {'success': false, 'status': status, 'message': msg};
      } else {
        return {
          'success': false,
          'status': status,
          'message': 'Erro ao autenticar (status $status).'
        };
      }
    } catch (e) {
      print('Erro no AuthService.login: $e');
      return {
        'success': false,
        'message':
            'Falha ao conectar ao servidor. Certifique-se que a API está rodando e o endereço está correto.'
      };
    }
  }
}
