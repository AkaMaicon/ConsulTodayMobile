import 'package:flutter/material.dart';
import 'EditAppointmentPage.dart';

class AppointmentDetailPage extends StatefulWidget {
  final Map<String, dynamic> consulta;

  const AppointmentDetailPage({super.key, required this.consulta});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  late Map<String, dynamic> consultaAtual; // guarda os dados atuais

  @override
  void initState() {
    super.initState();
    consultaAtual = Map<String, dynamic>.from(widget.consulta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Botão voltar personalizado
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, consultaAtual); // devolve a consulta atual
          },
        ),
        title: const Text('Detalhes da Consulta'),
        // Botão editar no canto direito
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Abre a tela de edição e espera o resultado
              final consultaEditada = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditAppointmentPage(consulta: consultaAtual),
                ),
              );

              if (consultaEditada != null) {
                setState(() {
                  consultaAtual = consultaEditada; // atualiza localmente
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Consulta atualizada com sucesso')),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  consultaAtual['especialidade'],
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Médico: ${consultaAtual['medico']}',
                    style: const TextStyle(fontSize: 16)),
                Text('Data: ${consultaAtual['data']}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Status: ${consultaAtual['status']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: consultaAtual['status'] == 'Finalizada'
                          ? Colors.green
                          : Colors.red,
                    )),
                const SizedBox(height: 16),
                Text('Observação:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    )),
                Text(
                  consultaAtual['observacao'] ?? 'Nenhuma observação',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                // Botão extra para cancelar ou voltar
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, consultaAtual);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
