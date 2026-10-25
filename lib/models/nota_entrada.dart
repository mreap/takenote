import '../app/utils/formato.dart';
import 'nota.dart';

/// Datos del formulario de nota. Genera el cuerpo de `NotaCrear` o, al editar,
/// el de `NotaActualizar` solo con los campos que cambiaron.
class NotaEntrada {
  const NotaEntrada({
    required this.titulo,
    this.clasificador,
    this.descripcion,
    this.fechaNota,
    this.valor,
    this.revisada = false,
    this.prioritaria = false,
    this.publica = false,
  });

  final String titulo;
  final String? clasificador;
  final String? descripcion;
  final DateTime? fechaNota;
  final double? valor;
  final bool revisada;
  final bool prioritaria;
  final bool publica;

  /// Cuerpo de `POST /notas`. Omite los opcionales vacíos; sin `fecha_nota`
  /// el servidor asigna la fecha.
  Map<String, dynamic> aJsonCrear() => {
    'titulo': titulo,
    'clasificador': ?clasificador,
    'descripcion': ?descripcion,
    if (fechaNota != null) 'fecha_nota': Formato.fechaApi(fechaNota!),
    'valor': ?valor,
    'revisada': revisada,
    'prioritaria': prioritaria,
    'publica': publica,
  };

  /// Cuerpo de `PATCH /notas/{id}`: solo lo que difiere de [original]. Un
  /// opcional vaciado se envía como `null` para borrarlo.
  Map<String, dynamic> aJsonActualizar(Nota original) {
    final cambios = <String, dynamic>{};
    if (titulo != original.titulo) cambios['titulo'] = titulo;
    if (clasificador != original.clasificador) {
      cambios['clasificador'] = clasificador;
    }
    if (descripcion != original.descripcion) {
      cambios['descripcion'] = descripcion;
    }
    if (fechaNota != null &&
        Formato.fechaApi(fechaNota!) != Formato.fechaApi(original.fechaNota)) {
      cambios['fecha_nota'] = Formato.fechaApi(fechaNota!);
    }
    if (valor != original.valor) cambios['valor'] = valor;
    if (revisada != original.revisada) cambios['revisada'] = revisada;
    if (prioritaria != original.prioritaria) {
      cambios['prioritaria'] = prioritaria;
    }
    if (publica != original.publica) cambios['publica'] = publica;
    return cambios;
  }
}
