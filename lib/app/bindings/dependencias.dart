import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../data/api_client.dart';
import '../../data/local_cache.dart';
import '../../data/token_storage.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/ia_repository.dart';
import '../../repositories/notas_repository.dart';
import '../config/env.dart';

/// Registra los servicios globales antes de arrancar la app.
Future<void> registrarDependencias() async {
  final tokens = Get.put(TokenStorage(), permanent: true);
  final cache = Get.put(LocalCache(), permanent: true);
  final api = Get.put(
    ApiClient(tokenStorage: tokens, certificadosExtra: await _certificados()),
    permanent: true,
  );
  Get.put(AuthRepository(api, tokens, cache), permanent: true);
  Get.put(NotasRepository(api, cache), permanent: true);
  Get.put(IaRepository(api), permanent: true);

  final auth = Get.put(AuthController(Get.find()), permanent: true);
  api.alExpirarSesion = auth.sesionExpirada;
}

Future<List<List<int>>> _certificados() async {
  final certificados = <List<int>>[];
  for (final ruta in Env.certificadosExtra) {
    final datos = await rootBundle.load(ruta);
    certificados.add(datos.buffer.asUint8List());
  }
  return certificados;
}
