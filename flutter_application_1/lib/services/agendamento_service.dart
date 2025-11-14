import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/consulta_model.dart';
import '../config/api_config.dart';

class AgendamentoService {
  // ✅ Corrigido: incluir o prefixo /api/consultas
  final String baseUrl = "${ApiConfig.baseUrl}/api/consultas";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ✅ Listar agendamentos (consultas) do paciente autenticado
  Future<List<dynamic>> listarAgendamentos() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result is Map && result.containsKey('content')) {
        return result['content'];
      }
      return [];
    }

    throw Exception("Erro ao listar agendamentos: ${response.statusCode}");
  }

  /// ✅ Agendar consulta
  Future<void> agendarConsulta({
    required int idMedico,
    required String dataHora,
    required String especialidade,
  }) async {
    final token = await _getToken();

    final body = jsonEncode({
      'idMedico': idMedico,
      'dataHora': dataHora,
      'especialidade': especialidade,
    });

    // ✅ Endpoint correto: /api/consultas/agendar
    final response = await http.post(
      Uri.parse('$baseUrl/agendar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode != 201) {
      print("Erro ao agendar consulta: ${response.body}");
      throw Exception("Erro ao agendar: ${response.statusCode}");
    }
  }

  /// ✅ Buscar histórico de consultas do paciente
  Future<List<ConsultaModel>> obterConsultas() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final content = decoded['content'];
      return List<ConsultaModel>.from(
        content.map((c) => ConsultaModel.fromJson(c)),
      );
    } else {
      print("Erro ao buscar histórico (${response.statusCode}): ${response.body}");
      throw Exception("Erro ao buscar histórico: ${response.statusCode}");
    }
  }

Future<void> cancelarAgendamento(int idAgendamento) async {
  final token = await _getToken();
  if (token == null) throw Exception('Token não encontrado');

  final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/consultas/cancelar/$idAgendamento');

  final response = await http.delete(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "motivo": "Cancelado pelo paciente via aplicativo"
    }),
  );

  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");

  if (response.statusCode != 204) {
    throw Exception(
        "Erro ao cancelar consulta: ${response.statusCode} ${response.body}");
  }
}

  /// ✅ Listar horários livres de um médico
  Future<List<String>> listarHorariosLivres({
    required int idMedico,
    required String data, // formato YYYY-MM-DD
  }) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/horarios?idMedico=$idMedico&data=$data'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final dataResponse = json.decode(response.body);
      if (dataResponse is List) {
        return dataResponse.cast<String>();
      }
      return [];
    } else {
      throw Exception("Erro ao buscar horários: ${response.statusCode}");
    }
  }
}
