import 'package:get/get.dart';

import '../../controllers/splash_controller.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/registro_screen.dart';
import '../../screens/splash/splash_screen.dart';
import 'app_routes.dart';

/// Rutas con su binding: cada controlador vive mientras su pantalla esté abierta.
abstract final class AppPages {
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
  ];
}
