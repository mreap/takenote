import 'package:flutter/material.dart';

/// Messenger global para mostrar avisos desde cualquier capa con el tema de la app.
final avisosKey = GlobalKey<ScaffoldMessengerState>();

void mostrarAviso(String mensaje, {bool error = false}) {
  final messenger = avisosKey.currentState;
  if (messenger == null) return;
  final esquema = Theme.of(messenger.context).colorScheme;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: error ? TextStyle(color: esquema.onErrorContainer) : null,
        ),
        backgroundColor: error ? esquema.errorContainer : null,
      ),
    );
}

/// Diálogo de confirmación. Devuelve `true` si el usuario confirma.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String accion = 'Aceptar',
  bool destructiva = false,
}) async {
  final esquema = Theme.of(context).colorScheme;
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: destructiva
              ? FilledButton.styleFrom(
                  backgroundColor: esquema.error,
                  foregroundColor: esquema.onError,
                )
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(accion),
        ),
      ],
    ),
  );
  return respuesta ?? false;
}
