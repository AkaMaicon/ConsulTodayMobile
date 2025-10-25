import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MensagensPage.dart';

class ConversasPage extends StatefulWidget {
  const ConversasPage({Key? key}) : super(key: key);

  @override
  State<ConversasPage> createState() => _ConversasPageState();
}

class _ConversasPageState extends State<ConversasPage> {
  List<Map<String, dynamic>> conversas = [];
  String filtro = "";

  @override
  void initState() {
    super.initState();
    _carregarConversas();
  }

  Future<void> _carregarConversas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('conversas');

    if (data != null) {
      try {
        final lista = List<Map<String, dynamic>>.from(jsonDecode(data));

        conversas = lista.map((c) {
          return {
            "id": c["id"] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            "nome": c["nome"] ?? "Sem nome",
            "mensagens": c["mensagens"] is List
                ? List<Map<String, dynamic>>.from(c["mensagens"])
                : <Map<String, dynamic>>[],
          };
        }).toList();

        setState(() {});
      } catch (e) {
        conversas = [];
        await prefs.remove('conversas');
        setState(() {});
      }
    }
  }

  Future<void> _salvarConversas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('conversas', jsonEncode(conversas));
  }

  void _novaConversa() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nova conversa"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Digite o nome do contato",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              setState(() {
                conversas.add({
                  "id": DateTime.now().millisecondsSinceEpoch.toString(),
                  "nome": controller.text.trim(),
                  "mensagens": [],
                });
              });
              _salvarConversas();
              Navigator.pop(context);
            },
            child: const Text("Criar"),
          ),
        ],
      ),
    );
  }

  void _removerConversa(String id) {
    setState(() {
      conversas.removeWhere((c) => c["id"] == id);
    });
    _salvarConversas();
  }

  @override
  Widget build(BuildContext context) {
    final listaFiltrada = conversas.where((c) {
      return c["nome"].toLowerCase().contains(filtro.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversas"),
        backgroundColor: const Color(0xFF4122E5),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Pesquisar...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  filtro = value;
                });
              },
            ),
          ),
          Expanded(
            child: listaFiltrada.isEmpty
                ? const Center(child: Text("Nenhuma conversa encontrada"))
                : ListView.builder(
                    itemCount: listaFiltrada.length,
                    itemBuilder: (_, i) {
                      final conversa = listaFiltrada[i];
                      final mensagens = List<Map<String, dynamic>>.from(
                          conversa["mensagens"]);
                      final ultimaMensagem = mensagens.isNotEmpty
                          ? mensagens.last["texto"]
                          : "Sem mensagens";

                      return Dismissible(
                        key: Key(conversa["id"]),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _removerConversa(conversa["id"]),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(conversa["nome"]),
                          subtitle: Text(
                            ultimaMensagem,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MensagensPage(
                                  conversa: conversa,
                                ),
                              ),
                            );
                            _carregarConversas();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4122E5),
        onPressed: _novaConversa,
        child: const Icon(Icons.add),
      ),
    );
  }
}
