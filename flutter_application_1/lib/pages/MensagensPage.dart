import 'package:flutter/material.dart';

class MensagensPage extends StatelessWidget {
  const MensagensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(3, (index) => _buildMessageTile(index)),
      ),
    );
  }

  Widget _buildMessageTile(int index) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text('Dr. Fulano #$index'),
        subtitle: const Text('Olá! Como posso te ajudar?'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }
}
