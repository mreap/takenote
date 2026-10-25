import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/estado_vista.dart';
import '../../controllers/splash_controller.dart';
import '../../widgets/vista_estado.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Obx(
        () => controller.estado.value == EstadoVista.error
            ? MensajeEstado(
                icono: Icons.cloud_off_outlined,
                titulo: 'No se pudo verificar tu sesión',
                mensaje: controller.mensajeError,
                esError: true,
                accion: FilledButton.icon(
                  onPressed: controller.iniciar,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
                accionSecundaria: TextButton(
                  onPressed: controller.irALogin,
                  child: const Text('Ir a iniciar sesión'),
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'TakeNote',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
      ),
    ),
  );
}
