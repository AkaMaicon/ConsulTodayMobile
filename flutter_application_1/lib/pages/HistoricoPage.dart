// lib/pages/HistoricoPage.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/favorites_service.dart';
// Importa a página de detalhes
import 'AppointmentDetailPage.dart';
// Importe o serviço de favoritos; // ajuste o caminho conforme necessário

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  _HistoricoPageState createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  String _selectedFilter = 'Todas';

  final List<Map<String, dynamic>> _consultas = [
    {
      'id': 1,
      'especialidade': 'Cardiologia',
      'medico': 'Dr. João Silva',
      'data': '10/08/2025 14:00',
      'status': 'Finalizada',
      'observacao': 'Consulta de rotina'
    },
    {
      'id': 2,
      'especialidade': 'Dermatologia',
      'medico': 'Dra. Maria Oliveira',
      'data': '20/08/2025 09:30',
      'status': 'Cancelada',
      'observacao': 'Reação alérgica'
    },
    {
      'id': 3,
      'especialidade': 'Clínico Geral',
      'medico': 'Dr. Lucas Rocha',
      'data': '01/09/2025 15:00',
      'status': 'Finalizada',
      'observacao': 'Exames de sangue'
    },
  ];

  List<Map<String, dynamic>> get _filteredConsultas {
    if (_selectedFilter == 'Todas') return _consultas;
    return _consultas
        .where((c) => c['status'] == _selectedFilter)
        .toList();
  }

  Future<bool> _isFavorite(String id) async {
    return await FavoritesService.isFavorite(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Consultas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filtros
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todas', 'Finalizada', 'Cancelada']
                    .map((filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredConsultas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma consulta encontrada.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredConsultas.length,
                      itemBuilder: (context, index) {
                        final consulta = _filteredConsultas[index];

                        return InkWell(
                          onTap: () async {
                            final consultaAtualizada = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AppointmentDetailPage(consulta: consulta),
                              ),
                            );

                            if (consultaAtualizada != null) {
                              setState(() {
                                _consultas[index] = consultaAtualizada; // atualiza a lista
                              });
                            }
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    consulta['especialidade'],
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Médico: ${consulta['medico']}'),
                                  Text('Data: ${consulta['data']}'),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              consulta['status'] == 'Finalizada'
                                                  ? Colors.green[100]
                                                  : Colors.red[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          consulta['status'],
                                          style: TextStyle(
                                            color:
                                                consulta['status'] == 'Finalizada'
                                                    ? Colors.green[800]
                                                    : Colors.red[800],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // ⬇️ Botão de favorito
                                      FutureBuilder<bool>(
                                        future: _isFavorite(consulta['id'].toString()),
                                        builder: (context, snapshot) {
                                          final isFav = snapshot.data ?? false;
                                          return IconButton(
                                            icon: Icon(
                                              isFav ? Icons.star : Icons.star_border,
                                              color: Colors.yellow,
                                            ),
                                            onPressed: () async {
                                              await FavoritesService.toggleFavorite(consulta['id'].toString());
                                              setState(() {});
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
