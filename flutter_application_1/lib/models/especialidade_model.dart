class Especialidade {
  final int id;
  final String nome;

  Especialidade({required this.id, required this.nome});

  // Converte o JSON da API para um objeto Especialidade
  factory Especialidade.fromJson(Map<String, dynamic> json) {
    return Especialidade(
      id: json['id'],
      nome: json['nome'],
    );
  }
}