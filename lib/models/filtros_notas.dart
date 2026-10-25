import '../app/utils/formato.dart';

/// Filtros de `GET /notas`. `null` significa "sin filtrar".
class FiltrosNotas {
  const FiltrosNotas({
    this.clasificador,
    this.revisada,
    this.prioritaria,
    this.q,
    this.desde,
    this.hasta,
  });

  final String? clasificador;
  final bool? revisada;
  final bool? prioritaria;
  final String? q;
  final DateTime? desde;
  final DateTime? hasta;

  /// Filtros activos sin contar la búsqueda de texto (que tiene su propio campo).
  int get cantidadActivos => [
    clasificador,
    revisada,
    prioritaria,
    desde,
    hasta,
  ].where((f) => f != null).length;

  bool get vacio => cantidadActivos == 0 && (q == null || q!.isEmpty);

  FiltrosNotas conBusqueda(String? texto) => FiltrosNotas(
    clasificador: clasificador,
    revisada: revisada,
    prioritaria: prioritaria,
    q: texto == null || texto.trim().isEmpty ? null : texto.trim(),
    desde: desde,
    hasta: hasta,
  );

  Map<String, dynamic> aQuery() => {
    'clasificador': clasificador,
    'revisada': revisada,
    'prioritaria': prioritaria,
    'q': q,
    'desde': desde == null ? null : Formato.fechaApi(desde!),
    'hasta': hasta == null ? null : Formato.fechaApi(hasta!),
  };
}
