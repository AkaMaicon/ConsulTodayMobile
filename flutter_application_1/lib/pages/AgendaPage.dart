import 'package:flutter/material.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Consulta'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Selecione uma especialidade:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSpecialtyTile('Clínico Geral'),
          _buildSpecialtyTile('Dermatologista'),
          _buildSpecialtyTile('Cardiologista'),
          _buildSpecialtyTile('Ortopedista'),
        ],
      ),
    );
  }

  Widget _buildSpecialtyTile(String title) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_hospital, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }
}
