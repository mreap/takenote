import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/notas_controller.dart';
import '../../controllers/splash_controller.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/registro_screen.dart';
import '../../screens/notas/notas_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../middleware/auth_middleware.dart';
import 'app_routes.dart';

/// Rutas con su binding: cada controlador vive mientras su pantalla esté abierta.
abstract final class AppPages {
  static final _protegida = [AuthMiddleware()];

  static final paginas = <GetPage<dynamic>>[
    GetPage(
      name: Rutas.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put(SplashController(Get.find()));
      }),
    ),
    GetPage(name: Rutas.login, page: () => const LoginScreen()),
    GetPage(name: Rutas.registro, page: () => const RegistroScreen()),
    GetPage(
      name: Rutas.notas,
      page: () => const NotasScreen(),
      middlewares: _protegida,
      binding: BindingsBuilder(() {
        Get.put(
          NotasController(
            Get.find(),
            usuarioId: Get.find<AuthController>().usuario.value?.id,
          ),
        );
      }),
    ),
  ];
}
