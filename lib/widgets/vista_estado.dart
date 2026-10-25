import 'package:flutter/material.dart';

import '../controllers/estado_vista.dart';

/// Pinta cargando / vacío / error / datos según [estado], para que ninguna
/// pantalla quede en blanco.
class VistaEstado extends StatelessWidget {
  const VistaEstado({
    super.key,
    required this.estado,
    required this.contenido,
    this.mensajeError,
    this.onReintentar,
    this.vacio,
    this.inicial,
    this.textoCargando,
  });

  final EstadoVista estado;
  final WidgetBuilder contenido;
  final String? mensajeError;
  final VoidCallback? onReintentar;
  final Widget? vacio;
  final Widget? inicial;
  final String? textoCargando;

  @override
  Widget build(BuildContext context) => switch (estado) {
    EstadoVista.cargando => Cargando(texto: textoCargando),
    EstadoVista.error => MensajeEstado(
      icono: Icons.cloud_off_outlined,
      titulo: 'No se pudo cargar',
      mensaje: mensajeError ?? 'Ocurrió un error inesperado.',
      esError: true,
      accion: onReintentar == null
          ? null
          : FilledButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
    ),
    EstadoVista.vacio =>
      vacio ??
          const MensajeEstado(
            icono: Icons.inbox_outlined,
            titulo: 'No hay datos',
          ),
    EstadoVista.inicial => inicial ?? const SizedBox.shrink(),
    EstadoVista.datos => contenido(context),
  };
}

class Cargando extends StatelessWidget {
  const Cargando({super.key, this.texto});

  final String? texto;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        if (texto != null) ...[
          const SizedBox(height: 16),
          Text(texto!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    ),
  );
}

/// Mensaje centrado con ícono, usado para vacío y error. Es desplazable para
/// funcionar dentro de un `RefreshIndicator`.
class MensajeEstado extends StatelessWidget {
  const MensajeEstado({
    super.key,
    required this.icono,
    required this.titulo,
    this.mensaje,
    this.accion,
    this.accionSecundaria,
    this.esError = false,
  });

  final IconData icono;
  final String titulo;
  final String? mensaje;
  final Widget? accion;
  final Widget? accionSecundaria;
  final bool esError;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final color = esError ? tema.colorScheme.error : tema.colorScheme.primary;
    final contenido = Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 64, color: color),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: tema.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (mensaje != null) ...[
            const SizedBox(height: 8),
            Text(
              mensaje!,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (accion != null) ...[const SizedBox(height: 24), accion!],
          if (accionSecundaria != null) ...[
            const SizedBox(height: 8),
            accionSecundaria!,
          ],
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, restricciones) {
        // Dentro de otra lista (altura sin límite) se pinta tal cual.
        if (!restricciones.hasBoundedHeight) return Center(child: contenido);
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: restricciones.maxHeight),
            child: Center(child: contenido),
          ),
        );
      },
    );
  }
}
