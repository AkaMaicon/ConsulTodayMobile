import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/medico_model.dart';
import 'package:flutter_application_1/models/especialidade_model.dart';

class ConsultaService {
  // ATENÇÃO: Use o IP da sua máquina, não localhost.
  // Se estiver no emulador Android, use 10.0.2.2
  static const String _baseUrl = 'http://localhost:8080'; // Exemplo! Verifique sua porta.

  // O método de agendamento
  // Os parâmetros (data, idMedico etc.) dependem do que a API espera!
  Future<bool> agendarConsulta({
    required DateTime dataHora,
    required int idMedico,
    required int idEspecialidade,
  }) async {
    // 1. Obter o token salvo
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token'); // Use a chave que você salvou no login

    if (token == null) {
      print("Erro: Token não encontrado.");
      return false;
    }

    // 2. Montar o body da requisição
    final body = json.encode({
      'dataHora': dataHora.toIso8601String(), // Envia em formato ISO
      'idMedico': idMedico,
      'idEspecialidade': idEspecialidade,
      // Se a API não pegar o ID do paciente pelo token,
      // você precisará enviá-lo aqui (obtenha ele após o login).
    });

    // 3. Fazer a requisição POST
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/consultas'), // Verifique o endpoint correto!
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Envia o token
        },
        body: body,
      );

      // 4. Tratar a resposta
      if (response.statusCode == 201) { // 201 (Created) é comum para POST
        print("Consulta agendada com sucesso!");
        return true;
      } else {
        print("Falha ao agendar: ${response.statusCode}");
        print("Corpo da resposta: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erro na requisição: $e");
      return false;
    }
  }

  Future<List<Especialidade>> getEspecialidades() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Token não encontrado.");
    }

    try {
      // ATENÇÃO: Confirme se o endpoint é /especialidades
      final response = await http.get(
        Uri.parse('$_baseUrl/especialidades'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Usamos utf8.decode para garantir acentuação correta (ex: "Clínico")
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = json.decode(responseBody);

        return jsonList.map((json) => Especialidade.fromJson(json)).toList();
      } else {
        throw Exception("Falha ao carregar especialidades: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erro ao buscar especialidades: $e");
    }
  }

  // NOVO MÉTODO: Buscar Médicos por Especialidade
  Future<List<Medico>> getMedicosPorEspecialidade(int especialidadeId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Token não encontrado.");
    }

    try {
      // ATENÇÃO: Confirme o endpoint e o nome do parâmetro (ex: "especialidadeId")
      final response = await http.get(
        Uri.parse('$_baseUrl/medicos?especialidadeId=$especialidadeId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = json.decode(responseBody);

        return jsonList.map((json) => Medico.fromJson(json)).toList();
      } else {
        throw Exception("Falha ao carregar médicos: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erro ao buscar médicos: $e");
    }
  }
}