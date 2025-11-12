class ConsultaModel {
  final int id;
  final String paciente;
  final String medico;
  final String especialidade;
  final DateTime dataHora;

  ConsultaModel({
    required this.id,
    required this.paciente,
    required this.medico,
    required this.especialidade,
    required this.dataHora,
  });

  factory ConsultaModel.fromJson(Map<String, dynamic> json) {
    return ConsultaModel(
      id: json['id'],
      paciente: json['paciente'],
      medico: json['medico'],
      especialidade: json['especialidade'],
      dataHora: DateTime.parse(json['dataHora']),
    );
  }
}
