import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class UsuarioService {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Busca dados do usuário autenticado
  Future<Map<String, dynamic>> obterUsuario() async {
    final token = await getToken();
    if (token == null) throw Exception('Token não encontrado');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/pacientes'), // endpoint do backend
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar usuário: ${response.statusCode}');
    }
  }
}
