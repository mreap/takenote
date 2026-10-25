/// `SugerenciaNota`: propuesta de la IA para una nota.
class SugerenciaNota {
  const SugerenciaNota({
    required this.clasificador,
    required this.prioritaria,
    required this.tituloSugerido,
    required this.justificacion,
  });

  final String clasificador;
  final bool prioritaria;
  final String tituloSugerido;
  final String justificacion;

  factory SugerenciaNota.fromJson(Map<String, dynamic> json) => SugerenciaNota(
    clasificador: json['clasificador'] as String,
    prioritaria: json['prioritaria'] as bool,
    tituloSugerido: json['titulo_sugerido'] as String,
    justificacion: json['justificacion'] as String,
  );
}

/// `ResumenNotas`: resumen generado por la IA sobre un conjunto de notas.
class ResumenNotas {
  const ResumenNotas({
    required this.totalNotas,
    required this.resumen,
    required this.pendientesClave,
    required this.sugerencias,
  });

  final int totalNotas;
  final String resumen;
  final List<String> pendientesClave;
  final List<String> sugerencias;

  factory ResumenNotas.fromJson(Map<String, dynamic> json) => ResumenNotas(
    totalNotas: json['total_notas'] as int,
    resumen: json['resumen'] as String,
    pendientesClave: List<String>.from(json['pendientes_clave'] as List),
    sugerencias: List<String>.from(json['sugerencias'] as List),
  );
}
