import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/utils/formato.dart';
import '../../controllers/estado_vista.dart';
import '../../controllers/nota_detalle_controller.dart';
import '../../models/ia.dart';
import '../../models/nota.dart';
import '../../widgets/avisos.dart';
import '../../widgets/vista_estado.dart';

class NotaDetalleScreen extends GetView<NotaDetalleController> {
  const NotaDetalleScreen({super.key});

  Future<void> _eliminar(BuildContext context) async {
    final nota = controller.nota.value;
    if (nota == null) return;
    final ok = await confirmar(
      context,
      titulo: 'Eliminar nota',
      mensaje: '¿Eliminar "${nota.titulo}"? Esta acción no se puede deshacer.',
      accion: 'Eliminar',
      destructiva: true,
    );
    if (!ok) return;
    final error = await controller.eliminar();
    if (error != null) {
      mostrarAviso(error, error: true);
      return;
    }
    Get.back();
    mostrarAviso('Nota eliminada');
  }

  Future<void> _alternar(String campo) async {
    final error = await controller.alternar(campo);
    if (error != null) mostrarAviso(error, error: true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Nota'),
      actions: [
        Obx(
          () => controller.estado.value == EstadoVista.datos
              ? Row(
                  children: [
                    IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => Get.toNamed(
                        Rutas.formulario,
                        arguments: controller.nota.value,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: controller.procesando.value
                          ? null
                          : () => _eliminar(context),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    ),
    body: Obx(() {
      if (controller.estado.value == EstadoVista.error) {
        return MensajeEstado(
          icono: Icons.error_outline,
          titulo: 'No se pudo abrir la nota',
          mensaje: controller.mensajeError.value,
          esError: true,
          accion: FilledButton.icon(
            onPressed: controller.cargar,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
          accionSecundaria: TextButton(
            onPressed: () => Get.offAllNamed(Rutas.notas),
            child: const Text('Volver a mis notas'),
          ),
        );
      }
      final nota = controller.nota.value;
      if (nota == null) return const Cargando(texto: 'Cargando nota…');
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.procesando.value) const LinearProgressIndicator(),
          _Contenido(nota: nota),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Revisada'),
                  secondary: const Icon(Icons.task_alt),
                  value: nota.revisada,
                  onChanged: controller.procesando.value
                      ? null
                      : (_) => _alternar('revisada'),
                ),
                SwitchListTile(
                  title: const Text('Prioritaria'),
                  secondary: const Icon(Icons.flag_outlined),
                  value: nota.prioritaria,
                  onChanged: controller.procesando.value
                      ? null
                      : (_) => _alternar('prioritaria'),
                ),
                SwitchListTile(
                  title: const Text('Pública'),
                  subtitle: const Text('Visible para otros usuarios'),
                  secondary: const Icon(Icons.public),
                  value: nota.publica,
                  onChanged: controller.procesando.value
                      ? null
                      : (_) => _alternar('publica'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _TarjetaIa(),
        ],
      );
    }),
  );
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.nota});

  final Nota nota;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final secundario = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nota.titulo, style: tema.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (nota.clasificador != null)
              Chip(
                avatar: const Icon(Icons.label_outline, size: 18),
                label: Text(nota.clasificador!),
              ),
            Chip(
              avatar: const Icon(Icons.event_outlined, size: 18),
              label: Text(Formato.fechaCorta(nota.fechaNota)),
            ),
            if (nota.valor != null)
              Chip(
                avatar: const Icon(Icons.payments_outlined, size: 18),
                label: Text(Formato.valor(nota.valor!)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          nota.descripcion ?? 'Sin descripción.',
          style: nota.descripcion == null
              ? secundario
              : tema.textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'Registrada el ${Formato.fechaHora(nota.fechaRegistro)}',
          style: secundario,
        ),
      ],
    );
  }
}

/// Sugerencia de la IA: inicial, cargando, error y resultado.
class _TarjetaIa extends GetView<NotaDetalleController> {
  const _TarjetaIa();

  Future<void> _aplicar(bool cambiarTitulo) async {
    final error = await controller.aplicarSugerencia(
      cambiarTitulo: cambiarTitulo,
    );
    mostrarAviso(error ?? 'Sugerencia aplicada', error: error != null);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: tema.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Asistente IA', style: tema.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 12),
              ...switch (controller.estadoIa.value) {
                EstadoVista.cargando => [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text('Consultando al asistente…'),
                ],
                EstadoVista.error => [
                  Text(
                    controller.mensajeErrorIa.value,
                    style: TextStyle(color: tema.colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: controller.pedirSugerencia,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
                EstadoVista.datos when controller.sugerencia.value != null =>
                  _sugerencia(context, controller.sugerencia.value!),
                _ => [
                  Text(
                    'Pide una sugerencia de clasificador, prioridad y título.',
                    style: tema.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: controller.pedirSugerencia,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Sugerir con IA'),
                  ),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _sugerencia(BuildContext context, SugerenciaNota s) {
    final tema = Theme.of(context);
    final ocupado = controller.procesando.value;
    return [
      _Fila(etiqueta: 'Clasificador', valor: s.clasificador),
      _Fila(etiqueta: 'Prioritaria', valor: s.prioritaria ? 'Sí' : 'No'),
      _Fila(etiqueta: 'Título sugerido', valor: s.tituloSugerido),
      const SizedBox(height: 8),
      Text(
        s.justificacion,
        style: tema.textTheme.bodySmall?.copyWith(
          color: tema.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: ocupado ? null : () => _aplicar(false),
        child: const Text('Aplicar clasificador y prioridad'),
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        onPressed: ocupado ? null : () => _aplicar(true),
        child: const Text('Aplicar también el título'),
      ),
      TextButton(
        onPressed: ocupado ? null : controller.descartarSugerencia,
        child: const Text('Descartar'),
      ),
    ];
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(etiqueta, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(child: Text(valor)),
      ],
    ),
  );
}
