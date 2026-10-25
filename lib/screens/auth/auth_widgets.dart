import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Validaciones de los formularios de autenticación (según el contrato).
abstract final class ValidarAuth {
  static final _correo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? correo(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Ingresa tu correo.';
    return _correo.hasMatch(t) ? null : 'Ingresa un correo válido.';
  }

  static String? claveLogin(String? v) =>
      (v ?? '').isEmpty ? 'Ingresa tu clave.' : null;

  static String? claveNueva(String? v) {
    final t = v ?? '';
    if (t.length < 6) return 'La clave debe tener al menos 6 caracteres.';
    if (t.length > 72) return 'La clave admite máximo 72 caracteres.';
    return null;
  }

  static String? nombre(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Ingresa tu nombre.';
    return t.length > 120 ? 'Máximo 120 caracteres.' : null;
  }
}

/// Encabezado y contenedor común de login y registro.
class MarcoAuth extends StatelessWidget {
  const MarcoAuth({super.key, required this.subtitulo, required this.hijos});

  final String subtitulo;
  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.sticky_note_2_outlined,
                  size: 56,
                  color: tema.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'TakeNote',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  textAlign: TextAlign.center,
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                ...hijos,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Campo de clave con botón para mostrarla. La visibilidad es estado local (Rx).
class CampoClave extends StatefulWidget {
  const CampoClave({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.validator,
    this.errorServidor,
    this.accion = TextInputAction.done,
    this.alEnviar,
  });

  final TextEditingController controller;
  final String etiqueta;
  final FormFieldValidator<String> validator;
  final String? errorServidor;
  final TextInputAction accion;
  final VoidCallback? alEnviar;

  @override
  State<CampoClave> createState() => _CampoClaveState();
}

class _CampoClaveState extends State<CampoClave> {
  final _oculta = true.obs;

  @override
  Widget build(BuildContext context) => Obx(
    () => TextFormField(
      controller: widget.controller,
      obscureText: _oculta.value,
      textInputAction: widget.accion,
      onFieldSubmitted: (_) => widget.alEnviar?.call(),
      validator: widget.validator,
      forceErrorText: widget.errorServidor,
      decoration: InputDecoration(
        labelText: widget.etiqueta,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _oculta.value ? 'Mostrar clave' : 'Ocultar clave',
          icon: Icon(_oculta.value ? Icons.visibility : Icons.visibility_off),
          onPressed: _oculta.toggle,
        ),
      ),
    ),
  );
}
