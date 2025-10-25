import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LastAppointmentPage extends StatefulWidget {
  const LastAppointmentPage({super.key});

  @override
  _LastAppointmentPageState createState() => _LastAppointmentPageState();
}

class _LastAppointmentPageState extends State<LastAppointmentPage> {
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("appointments") ?? [];
    setState(() {
      _appointments = data.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Meus Agendamentos"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _appointments.isEmpty
          ? const Center(child: Text("Nenhum agendamento encontrado."))
          : ListView.separated(
              itemCount: _appointments.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                final date = DateTime.parse(appointment["date"]);
                return ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: Text(appointment["doctor"] ?? ""),
                  subtitle: Text(
                      "${date.day}/${date.month}/${date.year} - ${appointment["time"]}"),
                );
              },
            ),
    );
  }
}
