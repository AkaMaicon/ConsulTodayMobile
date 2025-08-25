import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/AgendaPage.dart';
import 'package:flutter_application_1/pages/HistoricoPage.dart';
import 'package:flutter_application_1/pages/MensagensPage.dart';
import 'package:flutter_application_1/pages/PerfilPage.dart';

class HomePageLogged extends StatefulWidget {
  const HomePageLogged({super.key});

  @override
  State<HomePageLogged> createState() => _HomePageLoggedState();
}

class _HomePageLoggedState extends State<HomePageLogged> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomeContent(),
    AgendaPage(),
    PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Consultas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar especialidade ou médico...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuButton(context, Icons.add_circle_outline, 'Agendar', const AgendaPage()),
                _buildMenuButton(context, Icons.history_toggle_off, 'Histórico', const HistoricoPage()),
                _buildMenuButton(context, Icons.chat_bubble_outline, 'Mensagens', const MensagensPage()),
                _buildMenuButton(context, Icons.person_outline, 'Perfil', const PerfilPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String label, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[50],
        foregroundColor: Colors.blue,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
