import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/agendamento_service.dart';
import 'package:flutter_application_1/services/medico_service.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({super.key});

  @override
  State<AgendamentoPage> createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _dataSelecionada;
  String? _horaSelecionada;
  String? _especialidadeSelecionada;
  int? _selectedMedicoId;

  bool _carregando = false;
  bool _carregandoMedicos = false;

  List<dynamic> _medicos = [];
  List<String> horariosDisponiveis = [
    "08:00", "09:00", "10:00", "11:00",
    "13:00", "14:00", "15:00", "16:00"
  ];

  @override
  void initState() {
    super.initState();
    _carregarMedicos();
  }

  Future<void> _carregarMedicos() async {
    setState(() => _carregandoMedicos = true);
    try {
      final lista = await MedicoService().listarMedicos();
      setState(() => _medicos = lista);
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro ao carregar médicos')));
    } finally {
      setState(() => _carregandoMedicos = false);
    }
  }

  Future<void> _selecionarData() async {
    DateTime? novaData = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (novaData != null) {
      setState(() => _dataSelecionada = novaData);
    }
  }

  Future<void> _agendar() async {
    if (_dataSelecionada == null || _horaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione data e horário')),
      );
      return;
    }

    if (_selectedMedicoId == null || _especialidadeSelecionada == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecione médico e especialidade')));
      return;
    }

    setState(() => _carregando = true);

    try {
      await AgendamentoService().agendarConsulta(
        idMedico: _selectedMedicoId!,
        dataHora:
            "${_dataSelecionada!.toIso8601String().split("T")[0]}T$_horaSelecionada:00",
        especialidade: _especialidadeSelecionada!,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Consulta agendada com sucesso!')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao agendar: $e')));
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Consulta')),
      body: _carregandoMedicos
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Especialidade'),
                      value: _especialidadeSelecionada,
                      items: const [
                        'CARDIOLOGIA',
                        'DERMATOLOGIA',
                        'ORTOPEDIA',
                        'GINECOLOGIA',
                        'PEDIATRIA'
                      ]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _especialidadeSelecionada = val;
                          _selectedMedicoId = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Médico'),
                      value: _selectedMedicoId,
                      items: _medicos
                          .where((m) => m['especialidade'] == _especialidadeSelecionada)
                          .map<DropdownMenuItem<int>>((m) => DropdownMenuItem<int>(
                                value: m['id'],
                                child: Text(m['nome']),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedMedicoId = val),
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: _selecionarData,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Data'),
                          controller: TextEditingController(
                            text: _dataSelecionada == null
                                ? ''
                                : "${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text("Horários disponíveis", style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: horariosDisponiveis.map((h) {
                        final selecionado = h == _horaSelecionada;
                        return ChoiceChip(
                          label: Text(h),
                          selected: selecionado,
                          onSelected: (_) => setState(() => _horaSelecionada = h),
                        );
                      }).toList(),
                    ),
                    const Spacer(),

                    ElevatedButton(
                      onPressed: _carregando ? null : _agendar,
                      child: _carregando
                          ? const CircularProgressIndicator()
                          : const Text('Agendar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
