import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_senhaController.text != _confirmaSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.register(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      telefone: _telefoneController.text.trim(),
      cpf: _cpfController.text.replaceAll(RegExp(r'\D'), ''),
      senha: _senhaController.text,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Erro ao cadastrar usuário.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo no topo
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo e título
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
                          "CRIAR NOVA CONTA",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Campos
                        _buildTextField("Nome completo :", _nomeController, false,
                            keyboardType: TextInputType.name,
                            validator: (v) => v!.isEmpty ? 'Informe seu nome' : null),
                        const SizedBox(height: 20),

                        _buildTextField("Email :", _emailController, false,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v!.isEmpty ? 'Informe seu e-mail' : null),
                        const SizedBox(height: 20),

                        _buildTextField("Telefone :", _telefoneController, false,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            validator: (v) => v!.isEmpty ? 'Informe seu telefone' : null),
                        const SizedBox(height: 20),

                        _buildTextField("CPF :", _cpfController, false,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            validator: (v) {
                              final digits = v!.replaceAll(RegExp(r'\D'), '');
                              if (digits.length != 11) return 'CPF deve ter 11 dígitos';
                              return null;
                            }),
                        const SizedBox(height: 20),

                        _buildTextField("Senha :", _senhaController, true,
                            validator: (v) => v!.isEmpty ? 'Informe sua senha' : null),
                        const SizedBox(height: 20),

                        _buildTextField("Confirmar Senha :", _confirmaSenhaController, true,
                            validator: (v) => v!.isEmpty ? 'Confirme sua senha' : null),
                        const SizedBox(height: 30),

                        // Botão principal
                        ElevatedButton(
                          onPressed: _isLoading ? null : _cadastrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(
                            _isLoading ? "Cadastrando..." : "CADASTRAR",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Link para login
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "Já tem uma conta? ",
                              style: const TextStyle(color: Colors.white70),
                              children: [
                                TextSpan(
                                  text: "Login",
                                  style: const TextStyle(
                                    color: Colors.lightBlueAccent,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),

                        // Informações de contato
                        _contactInfo(Icons.phone, "+55 (11) 91234-5678"),
                        const SizedBox(height: 8),
                        _contactInfo(Icons.language, "www.consultoday.com"),
                        const SizedBox(height: 8),
                        _contactInfo(Icons.location_on, "São Paulo - SP"),
                        const SizedBox(height: 30),

                        // Rodapé / Menu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _menuText('Sobre Nós', context),
                            _menuText('Ajuda', context),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================
  // Widgets auxiliares
  // =====================

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool obscureText, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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

  Widget _menuText(String text, BuildContext context) {
    return GestureDetector(
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
