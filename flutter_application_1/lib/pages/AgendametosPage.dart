import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/agendamento_service.dart';
import 'package:intl/intl.dart';

class AgendamentosPage extends StatefulWidget {
  const AgendamentosPage({super.key});

  @override
  State<AgendamentosPage> createState() => _AgendamentosPageState();
}

class _AgendamentosPageState extends State<AgendamentosPage> {
  bool _carregando = true;
  List<dynamic> _agendamentos = [];

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  String _formatarData(String dataISO) {
    try {
      final date = DateTime.parse(dataISO);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dataISO;
    }
  }

  Future<void> _carregarAgendamentos() async {
    setState(() => _carregando = true);
    try {
      final lista = await AgendamentoService().listarAgendamentos();
      setState(() => _agendamentos = lista);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar consultas')),
      );
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _cancelarConsulta(int idAgendamento) async {
    try {
      await AgendamentoService().cancelarAgendamento(idAgendamento);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consulta cancelada com sucesso!')),
      );
      _carregarAgendamentos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cancelar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Consultas')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _agendamentos.isEmpty
              ? const Center(child: Text('Nenhuma consulta agendada'))
              : ListView.builder(
                  itemCount: _agendamentos.length,
                  itemBuilder: (context, index) {
                    final ag = _agendamentos[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('Médico: ${ag['medicoNome'] ?? '---'}'),
                        subtitle: Text('Data: ${_formatarData(ag['dataHora'] ?? '')}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () => _cancelarConsulta(ag['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
