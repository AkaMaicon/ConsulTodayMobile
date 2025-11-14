import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MensagensPage extends StatefulWidget {
  final Map<String, dynamic> conversa;

  const MensagensPage({super.key, required this.conversa});

  @override
  State<MensagensPage> createState() => _MensagensPageState();
}

class _MensagensPageState extends State<MensagensPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> mensagens;
  bool _digitando = false;

  @override
  void initState() {
    super.initState();
    mensagens = [];

    if (widget.conversa["mensagens"] is List) {
      for (var m in widget.conversa["mensagens"]) {
        mensagens.add({
          "texto": m["texto"] ?? "",
          "remetente": m["remetente"] ?? "usuario",
          "hora": m["hora"] ?? DateTime.now().toIso8601String(),
        });
      }
    }
  }

  Future<void> _salvarMensagens() async {
    final prefs = await SharedPreferences.getInstance();
    final conversas = List<Map<String, dynamic>>.from(
      jsonDecode(prefs.getString("conversas") ?? "[]"),
    );

    final index = conversas.indexWhere((c) => c["id"] == widget.conversa["id"]);
    if (index != -1) {
      conversas[index]["mensagens"] = mensagens;
      await prefs.setString("conversas", jsonEncode(conversas));
    }
  }

  void _enviarMensagem(String texto) {
    if (texto.trim().isEmpty) return;

    final novaMensagem = {
      "texto": texto.trim(),
      "remetente": "usuario",
      "hora": DateTime.now().toIso8601String(),
    };

    setState(() {
      mensagens.add(novaMensagem);
      _digitando = true;
    });

    _controller.clear();
    _salvarMensagens();
    _scrollAteFim();

    // Resposta automática de teste
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _digitando = false;
        mensagens.add({
          "texto": "Olá, precisa de ajuda?",
          "remetente": "medico",
          "hora": DateTime.now().toIso8601String(),
        });
      });
      _salvarMensagens();
      _scrollAteFim();
    });
  }

  void _scrollAteFim() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatarHora(String horaIso) {
    try {
      final dt = DateTime.parse(horaIso);
      return DateFormat.Hm().format(dt);
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.black54),
            ),
            const SizedBox(width: 12),
            Text(
              widget.conversa["nome"] ?? "Dr. João Silva",
              style: const TextStyle(
                color: Color.fromARGB(221, 255, 255, 255),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: mensagens.length + (_digitando ? 1 : 0),
              itemBuilder: (_, i) {
                if (_digitando && i == mensagens.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Text(
                        "Digitando...",
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  );
                }

                final msg = mensagens[i];
                final isUsuario = msg["remetente"] == "usuario";
                final hora = _formatarHora(msg["hora"]);

                return Align(
                  alignment:
                      isUsuario ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isUsuario
                          ? const Color(0xFF1E88E5)
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft:
                            Radius.circular(isUsuario ? 20 : 5),
                        bottomRight:
                            Radius.circular(isUsuario ? 5 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg["texto"],
                          style: TextStyle(
                            color: isUsuario ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hora,
                          style: TextStyle(
                            fontSize: 11,
                            color: isUsuario
                                ? Colors.white70
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// Campo de mensagem
          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.black12, width: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Digite sua mensagem...",
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _enviarMensagem,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _enviarMensagem(_controller.text),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E88E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
