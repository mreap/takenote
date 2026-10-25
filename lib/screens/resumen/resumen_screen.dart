import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/estado_vista.dart';
import '../../controllers/resumen_controller.dart';
import '../../models/ia.dart';
import '../../widgets/campo_fecha.dart';
import '../../widgets/vista_estado.dart';

class ResumenScreen extends GetView<ResumenController> {
  const ResumenScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Resumen con IA')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _Criterios(),
        const SizedBox(height: 24),
        Obx(
          () => VistaEstado(
            estado: controller.estado.value,
            mensajeError: controller.mensajeError.value,
            onReintentar: controller.generar,
            textoCargando: 'El asistente está preparando el resumen…',
            inicial: const _Aviso(
              icono: Icons.auto_awesome_outlined,
              texto:
                  'Elige los criterios y pulsa "Generar resumen" para que la IA '
                  'analice tus notas.',
            ),
            vacio: const _Aviso(
              icono: Icons.inbox_outlined,
              texto:
                  'No hay notas que cumplan esos criterios. Prueba con otro '
                  'rango de fechas o desactiva "Solo pendientes".',
            ),
            contenido: (_) =>
                Obx(() => _Resultado(controller.resultado.value!)),
          ),
        ),
      ],
    ),
  );
}

class _Criterios extends GetView<ResumenController> {
  const _Criterios();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: CampoFecha(
                    etiqueta: 'Desde',
                    valor: controller.desde.value,
                    alCambiar: (f) => controller.desde.value = f,
                    textoVacio: 'Cualquiera',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoFecha(
                    etiqueta: 'Hasta',
                    valor: controller.hasta.value,
                    alCambiar: (f) => controller.hasta.value = f,
                    textoVacio: 'Cualquiera',
                  ),
                ),
              ],
            ),
            if (controller.errorRango != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  controller.errorRango!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.clasificador,
              decoration: const InputDecoration(
                labelText: 'Clasificador (opcional)',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Solo pendientes'),
              subtitle: const Text('Ignora las notas ya revisadas'),
              value: controller.soloPendientes.value,
              onChanged: (v) => controller.soloPendientes.value = v,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed:
                  controller.estado.value == EstadoVista.cargando ||
                      controller.errorRango != null
                  ? null
                  : controller.generar,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generar resumen'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icono, size: 48, color: tema.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Resultado extends StatelessWidget {
  const _Resultado(this.r);

  final ResumenNotas r;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${r.totalNotas} ${r.totalNotas == 1 ? 'nota analizada' : 'notas analizadas'}',
          style: tema.textTheme.labelLarge?.copyWith(
            color: tema.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(r.resumen, style: tema.textTheme.bodyLarge),
        if (r.pendientesClave.isNotEmpty)
          _Lista(
            titulo: 'Pendientes clave',
            icono: Icons.flag_outlined,
            items: r.pendientesClave,
          ),
        if (r.sugerencias.isNotEmpty)
          _Lista(
            titulo: 'Sugerencias',
            icono: Icons.lightbulb_outline,
            items: r.sugerencias,
          ),
      ],
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({
    required this.titulo,
    required this.icono,
    required this.items,
  });

  final String titulo;
  final IconData icono;
  final List<String> items;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final item in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(icono, color: Theme.of(context).colorScheme.tertiary),
            title: Text(item),
          ),
      ],
    ),
  );
}
