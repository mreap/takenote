import 'package:flutter/material.dart';

/// Lista con "deslizar para refrescar" y carga de la siguiente página al
/// acercarse al final. Muestra el progreso o el error de la paginación al pie.
class ListaPaginada extends StatelessWidget {
  const ListaPaginada({
    super.key,
    required this.cantidad,
    required this.itemBuilder,
    required this.onRefrescar,
    required this.onCargarMas,
    required this.cargandoMas,
    this.errorPaginacion,
  });

  final int cantidad;
  final IndexedWidgetBuilder itemBuilder;
  final Future<void> Function() onRefrescar;
  final VoidCallback onCargarMas;
  final bool cargandoMas;
  final String? errorPaginacion;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefrescar,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.extentAfter < 300) onCargarMas();
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: cantidad + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) =>
              i < cantidad ? itemBuilder(context, i) : _pie(context),
        ),
      ),
    );
  }

  Widget _pie(BuildContext context) {
    if (cargandoMas) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (errorPaginacion != null) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              errorPaginacion!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            TextButton.icon(
              onPressed: onCargarMas,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
