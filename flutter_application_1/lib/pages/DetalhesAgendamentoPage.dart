import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetalhesAgendamentoPage extends StatelessWidget {
  final Map agendamento;

  const DetalhesAgendamentoPage({super.key, required this.agendamento});

  String _formatarData(String dataISO) {
    try {
      final date = DateTime.parse(dataISO);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dataISO;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nomeMedico = agendamento['nomeMedico'] ?? '---';
    final dataHora = _formatarData(agendamento['dataHora'] ?? '');
    final status = agendamento['status'] ?? '---';
    final observacoes = agendamento['observacoes'] ?? 'Nenhuma';

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Consulta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dr(a). $nomeMedico', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Data e Hora: $dataHora', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Status: $status', style: TextStyle(fontSize: 16, color: status == 'CANCELADO' ? Colors.red : Colors.green)),
            const SizedBox(height: 16),
            const Text('Observações:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(observacoes, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
