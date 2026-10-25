import '../app/utils/formato.dart';

/// `NotaOut` del contrato.
class Nota {
  const Nota({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.fechaNota,
    required this.fechaRegistro,
    this.clasificador,
    this.descripcion,
    this.valor,
    this.revisada = false,
    this.prioritaria = false,
    this.publica = false,
  });

  final int id;
  final int usuarioId;
  final String titulo;
  final String? clasificador;
  final String? descripcion;
  final DateTime fechaNota;
  final DateTime fechaRegistro;
  final double? valor;
  final bool revisada;
  final bool prioritaria;
  final bool publica;

  factory Nota.fromJson(Map<String, dynamic> json) => Nota(
    id: json['id'] as int,
    usuarioId: json['usuario_id'] as int,
    titulo: json['titulo'] as String,
    clasificador: json['clasificador'] as String?,
    descripcion: json['descripcion'] as String?,
    fechaNota: Formato.leerFechaApi(json['fecha_nota'])!,
    fechaRegistro: DateTime.parse(json['fecha_registro'] as String),
    valor: (json['valor'] as num?)?.toDouble(),
    revisada: json['revisada'] as bool? ?? false,
    prioritaria: json['prioritaria'] as bool? ?? false,
    publica: json['publica'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'titulo': titulo,
    'clasificador': clasificador,
    'descripcion': descripcion,
    'fecha_nota': Formato.fechaApi(fechaNota),
    'fecha_registro': fechaRegistro.toIso8601String(),
    'valor': valor,
    'revisada': revisada,
    'prioritaria': prioritaria,
    'publica': publica,
  };
}

/// `NotaPublicaOut`: una nota pública con el nombre de su autor.
class NotaPublica extends Nota {
  const NotaPublica({
    required super.id,
    required super.usuarioId,
    required super.titulo,
    required super.fechaNota,
    required super.fechaRegistro,
    required this.autor,
    super.clasificador,
    super.descripcion,
    super.valor,
    super.revisada,
    super.prioritaria,
    super.publica = true,
  });

  final String autor;

  factory NotaPublica.fromJson(Map<String, dynamic> json) {
    final n = Nota.fromJson(json);
    return NotaPublica(
      id: n.id,
      usuarioId: n.usuarioId,
      titulo: n.titulo,
      fechaNota: n.fechaNota,
      fechaRegistro: n.fechaRegistro,
      autor: json['autor'] as String,
      clasificador: n.clasificador,
      descripcion: n.descripcion,
      valor: n.valor,
      revisada: n.revisada,
      prioritaria: n.prioritaria,
      publica: n.publica,
    );
  }
}
