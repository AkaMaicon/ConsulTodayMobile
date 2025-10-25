import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // para formatar a data/hora

class EditAppointmentPage extends StatefulWidget {
  final Map<String, dynamic> consulta;

  const EditAppointmentPage({super.key, required this.consulta});

  @override
  State<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
  late TextEditingController _observacaoController;
  DateTime? _dataHora; // guarda a data/hora escolhida

  @override
  void initState() {
    super.initState();
    _observacaoController =
        TextEditingController(text: widget.consulta['observacao']);

    // tenta converter string em DateTime; se não der, pega agora
    try {
      _dataHora = DateFormat("dd/MM/yyyy HH:mm")
          .parse(widget.consulta['data']);
    } catch (_) {
      _dataHora = DateTime.now();
    }
  }

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataHora() async {
    // Selecionar data
    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _dataHora ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (dataEscolhida == null) return;

    // Selecionar hora
    final horaEscolhida = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataHora ?? DateTime.now()),
    );

    if (horaEscolhida == null) return;

    final novaDataHora = DateTime(
      dataEscolhida.year,
      dataEscolhida.month,
      dataEscolhida.day,
      horaEscolhida.hour,
      horaEscolhida.minute,
    );

    setState(() {
      _dataHora = novaDataHora;
    });
  }

  void _salvarAlteracoes() {
    // Formata a data/hora para string
    final dataHoraFormatada =
        DateFormat("dd/MM/yyyy HH:mm").format(_dataHora ?? DateTime.now());

    final consultaAtualizada = {
      ...widget.consulta,
      'observacao': _observacaoController.text,
      'data': dataHoraFormatada,
    };

    Navigator.pop(context, consultaAtualizada);
  }

  @override
  Widget build(BuildContext context) {
    final dataHoraFormatada = _dataHora != null
        ? DateFormat("dd/MM/yyyy HH:mm").format(_dataHora!)
        : 'Selecione a data e hora';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Editar Consulta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Campo de data/hora com botão para abrir o seletor
            InkWell(
              onTap: _selecionarDataHora,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data e Hora da Consulta',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  dataHoraFormatada,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacaoController,
              decoration: const InputDecoration(
                labelText: 'Observação',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _salvarAlteracoes,
              icon: const Icon(Icons.save),
              label: const Text('Salvar alterações'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
