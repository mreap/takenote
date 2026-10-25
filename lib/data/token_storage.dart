import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Único lugar donde se guarda el JWT (almacenamiento seguro del sistema).
/// Mantiene una copia en memoria para no leer el almacén en cada petición.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? almacen])
    : _almacen = almacen ?? const FlutterSecureStorage();

  static const _clave = 'takenote_jwt';

  final FlutterSecureStorage _almacen;
  String? _enMemoria;
  bool _leido = false;

  Future<String?> leer() async {
    if (!_leido) {
      _enMemoria = await _almacen.read(key: _clave);
      _leido = true;
    }
    return _enMemoria;
  }

  Future<void> guardar(String token) async {
    await _almacen.write(key: _clave, value: token);
    _enMemoria = token;
    _leido = true;
  }

  Future<void> borrar() async {
    await _almacen.delete(key: _clave);
    _enMemoria = null;
    _leido = true;
  }
}
