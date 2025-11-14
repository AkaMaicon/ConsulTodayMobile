import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/agendamento_service.dart';
import 'package:intl/intl.dart';
import 'DetalhesAgendamentoPage.dart';

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
      await _carregarAgendamentos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cancelar: $e')),
      );
    }
  }

  Future<void> _confirmarCancelamento(int idAgendamento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar consulta'),
        content: const Text('Tem certeza que deseja cancelar esta consulta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      _cancelarConsulta(idAgendamento);
    }
  }

  Widget _buildItem(Map ag, {bool cancelado = false}) {
    final nomeMedico = ag['nomeMedico'] ?? '---';
    final dataHora = _formatarData(ag['dataHora'] ?? '');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cancelado ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        title: Text(
          'Dr(a). $nomeMedico',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: cancelado ? Colors.red.shade700 : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            dataHora,
            style: TextStyle(
              fontSize: 14,
              color: cancelado ? Colors.red.shade300 : Colors.black54,
            ),
          ),
        ),
        trailing: cancelado
            ? null
            : IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                tooltip: 'Cancelar consulta',
                onPressed: () => _confirmarCancelamento(ag['idAgendamento']),
              ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalhesAgendamentoPage(agendamento: ag),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              'Nenhuma consulta agendada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Agende uma nova consulta e ela aparecerá aqui.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ativas = _agendamentos.where((a) => a['status'] != 'CANCELADO').toList();
    final canceladas = _agendamentos.where((a) => a['status'] == 'CANCELADO').toList();

    return Scaffold(
      backgroundColor: Colors.blue.shade50,

      appBar: AppBar(
        title: const Text(
          'Minhas Consultas',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarAgendamentos,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // ATIVAS
                  if (ativas.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(
                        'Consultas Ativas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ...ativas.map((ag) => _buildItem(ag)).toList(),
                  ],

                  // CANCELADAS
                  if (canceladas.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(
                        'Consultas Canceladas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    ...canceladas
                        .map((ag) => _buildItem(ag, cancelado: true))
                        .toList(),
                  ],

                  if (_agendamentos.isEmpty) _buildEmptyState(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
