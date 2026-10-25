import '../data/api_client.dart';
import '../data/api_exception.dart';
import '../data/local_cache.dart';
import '../data/token_storage.dart';
import '../models/usuario.dart';

class AuthRepository {
  AuthRepository(this._api, this._tokenStorage, this._cache);

  final ApiClient _api;
  final TokenStorage _tokenStorage;
  final LocalCache _cache;

  Future<Usuario> registrar({
    required String correo,
    required String nombre,
    required String clave,
  }) async {
    final json = await _api.post(
      '/auth/registro',
      datos: {'correo': correo, 'nombre': nombre, 'clave': clave},
      sinToken: true,
    );
    return convertirRespuesta(
      json,
      (d) => Usuario.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Inicia sesión y guarda el token en el almacenamiento seguro.
  Future<Usuario> login({required String correo, required String clave}) async {
    final datos = await _api.post(
      '/auth/login',
      datos: {'correo': correo, 'clave': clave},
      sinToken: true,
    );
    final (token, usuario) = convertirRespuesta(datos, (d) {
      final json = d as Map<String, dynamic>;
      return (
        json['access_token'] as String,
        Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
      );
    });
    await _tokenStorage.guardar(token);
    await _cache.guardarUsuario(usuario.toJson());
    return usuario;
  }

  /// Valida el token guardado contra `GET /auth/me`.
  Future<Usuario> perfil() async {
    final usuario = convertirRespuesta(
      await _api.get('/auth/me'),
      (d) => Usuario.fromJson(d as Map<String, dynamic>),
    );
    await _cache.guardarUsuario(usuario.toJson());
    return usuario;
  }

  Future<bool> tieneToken() async => await _tokenStorage.leer() != null;

  /// Último usuario conocido, para entrar sin conexión con un token guardado.
  Usuario? usuarioGuardado() {
    final json = _cache.leerUsuario();
    return json == null ? null : Usuario.fromJson(json);
  }

  Future<void> cerrarSesion() async {
    await _tokenStorage.borrar();
    await _cache.limpiar();
  }
}
