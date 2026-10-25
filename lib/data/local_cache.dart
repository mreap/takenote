import 'package:get_storage/get_storage.dart';

/// Persistencia local no sensible (get_storage). Nunca guarda el token.
/// Las notas se guardan por usuario para no mostrar datos de otra cuenta.
class LocalCache {
  LocalCache([GetStorage? caja]) : _caja = caja ?? GetStorage();

  final GetStorage _caja;

  static const _usuario = 'usuario';
  static String _notas(int usuarioId) => 'notas_$usuarioId';

  Map<String, dynamic>? leerUsuario() => _mapa(_caja.read(_usuario));

  Future<void> guardarUsuario(Map<String, dynamic> json) =>
      _caja.write(_usuario, json);

  List<Map<String, dynamic>>? leerNotas(int usuarioId) {
    final datos = _caja.read(_notas(usuarioId));
    if (datos is! List) return null;
    return datos.map(_mapa).whereType<Map<String, dynamic>>().toList();
  }

  Future<void> guardarNotas(int usuarioId, List<Map<String, dynamic>> notas) =>
      _caja.write(_notas(usuarioId), notas);

  Future<void> limpiar() => _caja.erase();

  static Map<String, dynamic>? _mapa(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : null;
}
