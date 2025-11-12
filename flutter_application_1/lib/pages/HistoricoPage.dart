import 'package:flutter/material.dart';
import '../services/agendamento_service.dart';
import '../models/consulta_model.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  final AgendamentoService agendamentoService = AgendamentoService();

  late Future<List<ConsultaModel>> _futureConsultas;

  @override
  void initState() {
    super.initState();
    _futureConsultas = agendamentoService.obterConsultas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Histórico de Consultas")),
      body: FutureBuilder<List<ConsultaModel>>(
        future: _futureConsultas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar consultas"));
          }

          final consultas = snapshot.data ?? [];

          if (consultas.isEmpty) {
            return Center(child: Text("Nenhuma consulta encontrada"));
          }

          return ListView.builder(
            itemCount: consultas.length,
            itemBuilder: (_, i) {
              final c = consultas[i];
              return Card(
                child: ListTile(
                  title: Text("${c.medico} — ${c.especialidade}"),
                  subtitle: Text(
                      "${c.paciente}\n${c.dataHora.day}/${c.dataHora.month}/${c.dataHora.year} ${c.dataHora.hour}:${c.dataHora.minute.toString().padLeft(2, '0')}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
