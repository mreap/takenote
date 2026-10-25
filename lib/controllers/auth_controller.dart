import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import '../data/api_exception.dart';
import '../models/usuario.dart';
import '../repositories/auth_repository.dart';
import '../widgets/avisos.dart';

enum ResultadoSesion { autenticado, sinSesion, error }

/// Sesión global de la app (registrado como permanente).
class AuthController extends GetxController {
  AuthController(this._repo);

  final AuthRepository _repo;

  final usuario = Rxn<Usuario>();
  final cargando = false.obs;
  final mensajeError = RxnString();
  final erroresCampo = <String, String>{}.obs;

  bool get autenticado => usuario.value != null;

  /// Restaura la sesión al abrir la app. Con token pero sin conexión entra
  /// con el último usuario conocido para poder ver la copia local.
  Future<ResultadoSesion> restaurarSesion() async {
    mensajeError.value = null;
    if (!await _repo.tieneToken()) return ResultadoSesion.sinSesion;
    try {
      usuario.value = await _repo.perfil();
      return ResultadoSesion.autenticado;
    } on ApiException catch (e) {
      if (e.tipo == TipoError.noAutorizado) {
        await _repo.cerrarSesion();
        return ResultadoSesion.sinSesion;
      }
      final guardado = _repo.usuarioGuardado();
      if (guardado != null &&
          (e.tipo == TipoError.sinConexion || e.tipo == TipoError.timeout)) {
        usuario.value = guardado;
        return ResultadoSesion.autenticado;
      }
      mensajeError.value = e.mensaje;
      return ResultadoSesion.error;
    }
  }

  Future<bool> login(String correo, String clave) => _conCarga(() async {
    usuario.value = await _repo.login(correo: correo.trim(), clave: clave);
  }, mensajeEn401: 'Correo o clave incorrectos.');

  /// Registra la cuenta e inicia sesión con ella.
  Future<bool> registrar(String nombre, String correo, String clave) =>
      _conCarga(() async {
        await _repo.registrar(
          correo: correo.trim(),
          nombre: nombre.trim(),
          clave: clave,
        );
        usuario.value = await _repo.login(correo: correo.trim(), clave: clave);
      }, mensajeEn409: 'Ese correo ya está registrado. Inicia sesión.');

  Future<bool> _conCarga(
    Future<void> Function() accion, {
    String? mensajeEn401,
    String? mensajeEn409,
  }) async {
    cargando.value = true;
    mensajeError.value = null;
    erroresCampo.clear();
    try {
      await accion();
      return true;
    } on ApiException catch (e) {
      erroresCampo.assignAll(e.erroresCampo);
      mensajeError.value = switch (e.tipo) {
        TipoError.noAutorizado when mensajeEn401 != null => mensajeEn401,
        TipoError.conflicto when mensajeEn409 != null => mensajeEn409,
        _ => e.mensaje,
      };
      return false;
    } finally {
      cargando.value = false;
    }
  }

  void limpiarError() {
    mensajeError.value = null;
    erroresCampo.clear();
  }

  Future<void> cerrarSesion() async {
    await _repo.cerrarSesion();
    usuario.value = null;
    Get.offAllNamed(Rutas.login);
  }

  /// Llamado por el cliente HTTP ante un 401 con token.
  Future<void> sesionExpirada() async {
    if (!autenticado) return;
    await cerrarSesion();
    mostrarAviso(
      'Tu sesión no es válida o expiró. Inicia sesión de nuevo.',
      error: true,
    );
  }
}
