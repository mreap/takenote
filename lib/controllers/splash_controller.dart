import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import 'auth_controller.dart';
import 'estado_vista.dart';

/// Decide la pantalla inicial según la sesión guardada.
class SplashController extends GetxController {
  SplashController(this._auth);

  final AuthController _auth;

  final estado = EstadoVista.cargando.obs;

  String get mensajeError => _auth.mensajeError.value ?? '';

  @override
  void onReady() {
    super.onReady();
    iniciar();
  }

  Future<void> iniciar() async {
    estado.value = EstadoVista.cargando;
    switch (await _auth.restaurarSesion()) {
      case ResultadoSesion.autenticado:
        Get.offAllNamed(Rutas.notas);
      case ResultadoSesion.sinSesion:
        Get.offAllNamed(Rutas.login);
      case ResultadoSesion.error:
        estado.value = EstadoVista.error;
    }
  }

  void irALogin() => Get.offAllNamed(Rutas.login);
}
