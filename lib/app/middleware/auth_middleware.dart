import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../routes/app_routes.dart';

/// Protege las rutas que requieren sesión.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      Get.find<AuthController>().autenticado
      ? null
      : const RouteSettings(name: Rutas.login);
}
