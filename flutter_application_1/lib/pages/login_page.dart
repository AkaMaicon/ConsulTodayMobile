import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/HomePageLogged.dart';
import 'package:flutter_application_1/pages/cadastro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginPage({super.key});

  // ⬇️ Adicione este método
  Future<void> _saveUserData(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userName", userName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem fixa no topo
          Container(
            height: 250,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/ConsulToday.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Conteúdo principal rolável
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 200),

                // Container azul com bordas superiores arredondadas
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0a183d),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.health_and_safety, color: Colors.white, size: 32),
                          SizedBox(width: 10),
                          Text(
                            "ConsulToday",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Faça login",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildTextField("CPF :", _usernameController, false),
                      const SizedBox(height: 20),
                      _buildTextField("Email :", _emailController, false, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 20),
                      _buildTextField("Senha :", _passwordController, true),
                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: () async {
                          // Salva o nome do usuário antes de navegar
                          await _saveUserData(_usernameController.text);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomePageLogged()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CadastroPage()),
                          );
                        },
                        
                        child: Text.rich(
                          TextSpan(
                            text: "Não tem uma conta? ",
                            style: const TextStyle(color: Colors.white70),
                            children: [
                              TextSpan(
                                text: "Cadastre-se",
                                style: const TextStyle(
                                  color: Colors.lightBlueAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      _contactInfo(Icons.phone, "+123-456-7890"),
                      const SizedBox(height: 8),
                      _contactInfo(Icons.language, "www.reallygreatsite.com"),
                      const SizedBox(height: 8),
                      _contactInfo(Icons.location_on, "123 Anywhere St., Any City"),
                      const SizedBox(height: 30),

                      // Menu no final da página
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _menuText('Home', context),
                          _menuText('Sobre Nós', context),
                          _menuText('Ajuda', context),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuText(String text, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (text == 'Home') {
          
        }
        // Adicionar outras rotas se necessário
      },
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool obscureText, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            hintStyle: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _contactInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
