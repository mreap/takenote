import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/notas_controller.dart';
import '../../models/nota.dart';
import '../../widgets/avisos.dart';
import '../../widgets/filtros_sheet.dart';
import '../../widgets/lista_paginada.dart';
import '../../widgets/nota_card.dart';
import '../../widgets/vista_estado.dart';

class NotasScreen extends GetView<NotasController> {
  const NotasScreen({super.key});

  Future<void> _filtrar(BuildContext context) async {
    final nuevos = await mostrarFiltros(context, controller.filtros.value);
    if (nuevos != null) controller.aplicarFiltros(nuevos);
  }

  Future<void> _alternar(Nota nota) async {
    final error = await controller.alternarRevisada(nota);
    if (error != null) mostrarAviso(error, error: true);
  }

  Future<bool> _confirmarEliminar(BuildContext context, Nota nota) => confirmar(
    context,
    titulo: 'Eliminar nota',
    mensaje: '¿Eliminar "${nota.titulo}"? Esta acción no se puede deshacer.',
    accion: 'Eliminar',
    destructiva: true,
  );

  Future<void> _eliminar(Nota nota) async {
    final error = await controller.eliminar(nota);
    mostrarAviso(error ?? 'Nota eliminada', error: error != null);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mis notas'),
      actions: [
        Obx(
          () => IconButton(
            tooltip: 'Filtros',
            onPressed: () => _filtrar(context),
            icon: Badge(
              isLabelVisible: controller.filtros.value.cantidadActivos > 0,
              label: Text('${controller.filtros.value.cantidadActivos}'),
              child: const Icon(Icons.filter_list),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: controller.campoBusqueda,
            onChanged: (v) => controller.busqueda.value = v,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Buscar en mis notas',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
      ),
    ),
    drawer: const _MenuPrincipal(),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => Get.toNamed(Rutas.formulario),
      icon: const Icon(Icons.add),
      label: const Text('Nueva nota'),
    ),
    body: Column(
      children: [
        Obx(
          () => controller.mostrandoCopiaLocal.value
              ? MaterialBanner(
                  leading: const Icon(Icons.wifi_off),
                  content: Text(
                    'Sin conexión: estás viendo la última copia guardada. '
                    '${controller.mensajeError.value}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: controller.cargar,
                      child: const Text('Reintentar'),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        Expanded(
          child: Obx(
            () => VistaEstado(
              estado: controller.estado.value,
              mensajeError: controller.mensajeError.value,
              onReintentar: controller.cargar,
              vacio: controller.hayFiltros
                  ? MensajeEstado(
                      icono: Icons.search_off,
                      titulo: 'Sin resultados',
                      mensaje: 'Ninguna nota coincide con la búsqueda o los filtros.',
                      accion: OutlinedButton(
                        onPressed: controller.limpiarFiltros,
                        child: const Text('Limpiar filtros'),
                      ),
                    )
                  : MensajeEstado(
                      icono: Icons.note_add_outlined,
                      titulo: 'Aún no tienes notas',
                      mensaje: 'Crea tu primera nota para empezar.',
                      accion: FilledButton.icon(
                        onPressed: () => Get.toNamed(Rutas.formulario),
                        icon: const Icon(Icons.add),
                        label: const Text('Crear nota'),
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
                    final tarjeta = NotaCard(
                      nota: nota,
                      onTap: () => Get.toNamed(Rutas.detalle, arguments: nota),
                      onAlternarRevisada: controller.mostrandoCopiaLocal.value
                          ? null
                          : () => _alternar(nota),
                    );
                    if (controller.mostrandoCopiaLocal.value) return tarjeta;
                    return Dismissible(
                      key: ValueKey(nota.id),
                      direction: DismissDirection.endToStart,
                      background: const _FondoEliminar(),
                      confirmDismiss: (_) => _confirmarEliminar(context, nota),
                      onDismissed: (_) => _eliminar(nota),
                      child: tarjeta,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _FondoEliminar extends StatelessWidget {
  const _FondoEliminar();

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: esquema.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.delete_outline, color: esquema.onErrorContainer),
    );
  }
}

/// Menú lateral. Públicas y Resumen se abren encima de la lista (con flecha
/// para volver), así el botón atrás nunca deja la app sin salida.
class _MenuPrincipal extends StatelessWidget {
  const _MenuPrincipal();

  static const _rutas = [Rutas.notas, Rutas.publicas, Rutas.resumen];

  void _ir(String ruta) {
    Get.back();
    if (ruta != Rutas.notas) Get.toNamed(ruta);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return NavigationDrawer(
      selectedIndex: 0,
      onDestinationSelected: (i) => _ir(_rutas[i]),
      children: [
        Obx(
          () => UserAccountsDrawerHeader(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            accountName: Text(
              auth.usuario.value?.nombre ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            accountEmail: Text(
              auth.usuario.value?.correo ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              child: Text(
                (auth.usuario.value?.nombre.characters.firstOrNull ?? '?')
                    .toUpperCase(),
              ),
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.sticky_note_2_outlined),
          selectedIcon: Icon(Icons.sticky_note_2),
          label: Text('Mis notas'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.public_outlined),
          selectedIcon: Icon(Icons.public),
          label: Text('Notas públicas'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          selectedIcon: Icon(Icons.auto_awesome),
          label: Text('Resumen con IA'),
        ),
        const Divider(indent: 28, endIndent: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              final ok = await confirmar(
                context,
                titulo: 'Cerrar sesión',
                mensaje: '¿Quieres cerrar tu sesión en este dispositivo?',
                accion: 'Cerrar sesión',
              );
              if (ok) await auth.cerrarSesion();
            },
          ),
        ),
      ],
    );
  }
}
