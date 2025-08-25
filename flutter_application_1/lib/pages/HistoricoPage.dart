import 'package:flutter/material.dart';

class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Consultas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text('Consulta com Dr. Fulano #$index'),
              subtitle: const Text('20/07/2025 - 14:00'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
