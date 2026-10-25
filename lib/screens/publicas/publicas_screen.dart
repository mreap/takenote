import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/utils/formato.dart';
import '../../controllers/publicas_controller.dart';
import '../../models/nota.dart';
import '../../widgets/lista_paginada.dart';
import '../../widgets/nota_card.dart';
import '../../widgets/vista_estado.dart';

class PublicasScreen extends GetView<PublicasController> {
  const PublicasScreen({super.key});

  void _verNota(BuildContext context, NotaPublica nota) {
    final tema = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nota.titulo, style: tema.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Por ${nota.autor} · ${Formato.fechaCorta(nota.fechaNota)}',
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (nota.clasificador != null)
                    Chip(label: Text(nota.clasificador!)),
                  if (nota.valor != null)
                    Chip(label: Text(Formato.valor(nota.valor!))),
                  if (nota.prioritaria) const Chip(label: Text('Prioritaria')),
                ],
              ),
              const SizedBox(height: 12),
              Text(nota.descripcion ?? 'Sin descripción.'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Notas públicas'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: controller.campoBusqueda,
            onChanged: (v) => controller.busqueda.value = v,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Buscar en notas públicas',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
      ),
    ),
    body: Obx(
      () => VistaEstado(
        estado: controller.estado.value,
        mensajeError: controller.mensajeError.value,
        onReintentar: controller.cargar,
        vacio: MensajeEstado(
          icono: Icons.public_off_outlined,
          titulo: controller.busqueda.value.trim().isEmpty
              ? 'Todavía no hay notas públicas'
              : 'Sin resultados',
          mensaje: controller.busqueda.value.trim().isEmpty
              ? 'Cuando alguien comparta una nota aparecerá aquí.'
              : 'Ninguna nota pública coincide con la búsqueda.',
          accion: OutlinedButton.icon(
            onPressed: controller.cargar,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
          ),
        ),
        contenido: (context) => Obx(
          () => ListaPaginada(
            cantidad: controller.notas.length,
            onRefrescar: controller.cargar,
            onCargarMas: controller.cargarMas,
            cargandoMas: controller.cargandoMas.value,
            errorPaginacion: controller.errorPaginacion.value,
            itemBuilder: (context, i) {
              final nota = controller.notas[i];
              return NotaCard(
                nota: nota,
                autor: nota.autor,
                onTap: () => _verNota(context, nota),
              );
            },
          ),
        ),
      ),
    ),
  );
}
