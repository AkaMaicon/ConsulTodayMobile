import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'notification_service.dart'; // Importe o serviço de notificação

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  String? _selectedDoctor;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime; // agora é String

  final List<String> availableTimes = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00'
  ];

  final List<String> _doctors = [
    "Dr. João Silva",
    "Dra. Maria Oliveira",
    "Dr. Carlos Souza",
    "Dra. Ana Lima"
  ];

  Future<void> _saveAppointment() async {
    if (_selectedDoctor != null && _selectedDay != null && _selectedTime != null) {
      final prefs = await SharedPreferences.getInstance();

      final newAppointment = {
        "doctor": _selectedDoctor,
        "date": _selectedDay!.toIso8601String(),
        "time": _selectedTime,
      };

      List<String> appointments = prefs.getStringList("appointments") ?? [];
      appointments.add(jsonEncode(newAppointment));
      await prefs.setStringList("appointments", appointments);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agendamento salvo com sucesso!")),
      );

      // Supondo que o usuário escolheu a data/hora:
      final dataConsulta = DateTime.parse(
        "${_selectedDay!.toIso8601String().substring(0, 10)} $_selectedTime:00"
      );

      // Dispara notificação 1 hora antes
      final lembrete = dataConsulta.subtract(const Duration(hours: 1));

      await NotificationService.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID único
        title: "Lembrete de Consulta",
        body: "Você tem uma consulta com $_selectedDoctor às $_selectedTime.",
        scheduledDate: lembrete,
      );

      // Resetar seleção
      setState(() {
        _selectedDoctor = null;
        _selectedDay = null;
        _selectedTime = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, selecione todas as informações.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Consulta')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seleção de médico
              const Text(
                'Selecione o médico:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedDoctor,
                hint: const Text('Escolha um médico'),
                isExpanded: true,
                items: _doctors.map((doctor) {
                  return DropdownMenuItem<String>(
                    value: doctor,
                    child: Text(doctor),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDoctor = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Calendário
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.utc(2026, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedTime = null; // resetar horário ao mudar o dia
                  });
                },
                calendarFormat: CalendarFormat.twoWeeks,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 20),

              // Horários disponíveis
              if (_selectedDay != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horários disponíveis em ${_selectedDay!.day}/${_selectedDay!.month}:',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableTimes.map((time) {
                        final isSelected = _selectedTime == time;
                        return ChoiceChip(
                          label: Text(time),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedTime = time;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: (_selectedDoctor != null && _selectedDay != null && _selectedTime != null)
                      ? _saveAppointment
                      : null,
                  child: const Text('Confirmar Consulta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
