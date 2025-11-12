class Medico {
  final int id;
  final String nome;

  Medico({required this.id, required this.nome});

  // Converte o JSON da API para um objeto Medico
  factory Medico.fromJson(Map<String, dynamic> json) {
    return Medico(
      id: json['id'],
      nome: json['nome'],
    );
  }
}