import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/HistoricoPage.dart';
import 'package:flutter_application_1/pages/MensagensPage.dart';
import 'package:flutter_application_1/pages/PerfilPage.dart';
import 'package:flutter_application_1/pages/AgendamentoPage.dart';
import 'package:flutter_application_1/pages/AgendametosPage.dart';
import 'package:flutter_application_1/services/usuario_service.dart';
import 'package:flutter_application_1/services/agendamento_service.dart';
import 'package:flutter_application_1/pages/DetalhesAgendamentoPage.dart';

class HomePageLogged extends StatefulWidget {
  const HomePageLogged({super.key});

  @override
  State<HomePageLogged> createState() => _HomePageLoggedState();
}

class _HomePageLoggedState extends State<HomePageLogged> {
  int _selectedIndex = 0;
  String nomeUsuario = 'Usuário';
  bool carregandoUsuario = true;
  Map<String, dynamic>? proximaConsulta;
  bool carregandoConsulta = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
    _carregarProximaConsulta();
  }

  Future<void> _carregarUsuario() async {
    try {
      final usuarioData = await UsuarioService().obterUsuario();
      if (mounted) {
        setState(() {
          nomeUsuario = usuarioData['nome'] ?? 'Usuário';
          carregandoUsuario = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar usuário: $e');
      if (mounted) {
        setState(() {
          carregandoUsuario = false;
        });
      }
    }
  }

  Future<void> _carregarProximaConsulta() async {
    try {
      final agendamentos = await AgendamentoService().listarAgendamentos();
      if (mounted) {
        // Filtra apenas consultas futuras e não canceladas
        agendamentos.removeWhere((ag) => ag['status'] == 'CANCELADO');
        agendamentos.sort((a, b) => DateTime.parse(a['dataHora'])
            .compareTo(DateTime.parse(b['dataHora'])));
        setState(() {
          proximaConsulta =
              agendamentos.isNotEmpty ? agendamentos.first : null;
          carregandoConsulta = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar próxima consulta: $e');
      if (mounted) {
        setState(() {
          carregandoConsulta = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomeStartPage(
        nomeUsuario: nomeUsuario,
        carregandoUsuario: carregandoUsuario,
        proximaConsulta: proximaConsulta,
        carregandoConsulta: carregandoConsulta,
      ),
      HistoricoPage(),
      const AgendamentosPage(),
      const MensagensPage(conversa: {}),
      PerfilPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Agendamentos"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Mensagens"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}

/// Página inicial agora recebe o nome do usuário e a próxima consulta
class _HomeStartPage extends StatelessWidget {
  final String nomeUsuario;
  final bool carregandoUsuario;
  final Map<String, dynamic>? proximaConsulta;
  final bool carregandoConsulta;

  const _HomeStartPage({
    super.key,
    required this.nomeUsuario,
    required this.carregandoUsuario,
    this.proximaConsulta,
    required this.carregandoConsulta,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> dicasSaude = [
      'Beba pelo menos 2 litros de água por dia para manter-se hidratado!',
      'Durma ao menos 7-8 horas por noite para melhorar sua saúde.',
      'Pratique atividade física regularmente, mesmo que leve!',
      'Mantenha uma alimentação equilibrada com frutas e verduras.',
      'Lave bem as mãos para evitar transmissão de doenças.',
      'Evite excesso de açúcar e alimentos ultraprocessados.',
    ];

    final String dicaEscolhida = dicasSaude[Random().nextInt(dicasSaude.length)];

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("ConsulToday"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de boas-vindas
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.blueAccent, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: carregandoUsuario
                          ? const SizedBox(
                              height: 40,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Text(
                              'Olá, $nomeUsuario!\nSeja bem-vindo ao ConsulToday',
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Barra de pesquisa
            TextField(
              decoration: InputDecoration(
                hintText: "Pesquisar médicos, consultas...",
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botão agendar nova consulta
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Agendar nova consulta",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AgendamentoPage()),
                );
              },
            ),
            const SizedBox(height: 24),

            // Próxima consulta dinâmica
            Text('Sua próxima consulta', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            carregandoConsulta
                ? const Center(child: CircularProgressIndicator())
                : proximaConsulta == null
                    ? const Text('Nenhuma consulta agendada')
                    : Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.local_hospital, color: Colors.blueAccent),
                          title: Text(
                              '${proximaConsulta!['nomeMedico'] ?? 'Dr(a). ???'}'),
                          subtitle: Text(
                              '${proximaConsulta!['dataHora'] != null ? DateTime.parse(proximaConsulta!['dataHora']).toLocal().toString().substring(0,16) : 'Data não disponível'}'),
                          trailing: TextButton(
                              child: const Text('Ver detalhes'),
                              onPressed: () {
                                if (proximaConsulta != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetalhesAgendamentoPage(agendamento: proximaConsulta!),
                                    ),
                                  );
                                }
                              },
                            ),
                        ),
                      ),
            const SizedBox(height: 24),

            // Especialidades populares
            Text('Especialidades populares', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _especialidadeItem(Icons.favorite, 'Cardio'),
                _especialidadeItem(Icons.spa, 'Derma'),
                _especialidadeItem(Icons.visibility, 'Oftalmo'),
                _especialidadeItem(Icons.child_care, 'Pediatria'),
                _especialidadeItem(Icons.directions_walk, 'Ortopedia'),
                _especialidadeItem(Icons.more_horiz, 'Mais'),
              ],
            ),
            const SizedBox(height: 24),

            // Dica de saúde dinâmica
            Text('Dica de saúde do dia', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dicasSaude[Random().nextInt(dicasSaude.length)],
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _especialidadeItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          child: Icon(icon, color: Colors.blueAccent, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
