import 'package:flutter/material.dart';

/// Recuadro de error del formulario.
class ErrorFormulario extends StatelessWidget {
  const ErrorFormulario({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esquema.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: esquema.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(color: esquema.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
