import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/consulta_model.dart';

class AgendamentoService {
  static const String baseUrl = 'http://localhost:8080/api/consultas';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ✅ Listar agendamentos do paciente
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

      // API retorna Page, então buscamos content:
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

    final response = await http.post(
      Uri.parse('$baseUrl/agendar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception("Erro ao agendar: ${response.statusCode}");
    }
  }

  Future<List<ConsultaModel>> obterConsultas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

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
    print("Erro ao buscar histórico");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");
    throw Exception("Erro ao buscar histórico: ${response.statusCode}");
  }
  }

  /// ✅ Cancelar agendamento (backend exige body!)
  Future<void> cancelarAgendamento(int idAgendamento) async {
    final token = await _getToken();

    final body = jsonEncode({
      "motivo": "Cancelado pelo paciente"
    });

    final response = await http.delete(
      Uri.parse('$baseUrl/cancelar/$idAgendamento'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body, // obrigatório
    );

    if (response.statusCode != 204) {
      throw Exception("Erro ao cancelar: ${response.statusCode}");
    }
  }

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
