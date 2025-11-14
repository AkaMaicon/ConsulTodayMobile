import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  final String baseUrl = ApiConfig.baseUrl;

  String? extractEmailFromJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final data = jsonDecode(payload);

    return data["sub"];
  } catch (e) {
    print("Erro ao decodificar JWT: $e");
    return null;
  }
}
  /// Register a new paciente.
  /// Returns map: { 'success': bool, 'status': int?, 'message': String?, 'data': Map? }
  Future<Map<String, dynamic>> register({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
    required String cpf,
  }) async {
    final url = Uri.parse('$baseUrl/api/pacientes/cadastrar');
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
    final url = Uri.parse('$baseUrl/auth/login');
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
      print("🌐 LOGIN RESPONSE: ${response.body}");


      if (responseBody is Map) {
        final prefs = await SharedPreferences.getInstance();

        // Procurar direto no root
        String? name = responseBody['nome'];
        String? email = responseBody['email'];

        // Procurar dentro de usuario
        if (responseBody['usuario'] is Map) {
          name ??= responseBody['usuario']['nome'];
          email ??= responseBody['usuario']['email'];
        }

        // Procurar dentro de paciente
        if (responseBody['paciente'] is Map) {
          name ??= responseBody['paciente']['nome'];
          email ??= responseBody['paciente']['email'];
        }

        // Procurar dentro de data
        if (responseBody['data'] is Map) {
          name ??= responseBody['data']['nome'];
          email ??= responseBody['data']['email'];
        }

        // Salvar se achou
        if (name != null) await prefs.setString('user_name', name);
        if (email != null) await prefs.setString('user_email', email);

        if (responseBody.containsKey('id')) {
          await prefs.setInt('user_id', responseBody['id']);
        }
      }

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

        if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        final extractedEmail = extractEmailFromJwt(token);
        if (extractedEmail != null) {
          await prefs.setString('user_email', extractedEmail);
        }
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
