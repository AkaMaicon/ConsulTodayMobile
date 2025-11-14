import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/agendamento_service.dart';
import 'package:flutter_application_1/services/medico_service.dart';
import 'package:flutter_application_1/widgets/primary_button.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar médicos')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione médico e especialidade')),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consulta agendada com sucesso!')),
      );

      if (mounted) {
        Navigator.of(context).maybePop();
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao agendar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Agendar Consulta"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _carregandoMedicos
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Informações da consulta",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),

                            // ESPECIALIDADE
                            DropdownButtonFormField<String>(
                              decoration: _inputDecoration("Especialidade"),
                              value: _especialidadeSelecionada,
                              items: const [
                                'CARDIOLOGIA',
                                'DERMATOLOGIA',
                                'ORTOPEDIA',
                                'GINECOLOGIA',
                                'PEDIATRIA'
                              ]
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _especialidadeSelecionada = val;
                                  _selectedMedicoId = null;
                                });
                              },
                            ),
                            const SizedBox(height: 12),

                            // MÉDICO
                            DropdownButtonFormField<int>(
                              decoration: _inputDecoration("Médico"),
                              value: _selectedMedicoId,
                              items: _medicos
                                  .where((m) =>
                                      m['especialidade'] ==
                                      _especialidadeSelecionada)
                                  .map<DropdownMenuItem<int>>(
                                    (m) => DropdownMenuItem<int>(
                                      value: m['id'],
                                      child: Text(m['nome']),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedMedicoId = val),
                            ),
                            const SizedBox(height: 12),

                            // DATA
                            GestureDetector(
                              onTap: _selecionarData,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration:
                                      _inputDecoration("Data").copyWith(
                                    hintText: _dataSelecionada == null
                                        ? "Selecione a data"
                                        : "${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}",
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Text(
                              "Horários disponíveis",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),

                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: horariosDisponiveis.map((h) {
                                final selecionado = h == _horaSelecionada;
                                return ChoiceChip(
                                  label: Text(h),
                                  selected: selecionado,
                                  selectedColor: Colors.blue,
                                  backgroundColor: Colors.grey.shade200,
                                  labelStyle: TextStyle(
                                    color: selecionado
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  onSelected: (_) =>
                                      setState(() => _horaSelecionada = h),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    PrimaryButton(
                      label: "Agendar consulta",
                      loading: _carregando,
                      onPressed: _carregando ? null : _agendar,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.black87),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
