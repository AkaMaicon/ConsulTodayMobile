import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class MedicoService {
  // ✅ Corrigido: incluir o prefixo /api/medicos
  final String baseUrl = "${ApiConfig.baseUrl}/api/medicos";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ✅ Listar todos os médicos
  Future<List<dynamic>> listarMedicos() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map && data.containsKey('content')) {
        return data['content'];
      }
      return data;
    } else {
      print("Erro ao carregar médicos (${response.statusCode}): ${response.body}");
      throw Exception('Erro ao carregar médicos: ${response.statusCode}');
    }
  }
}
