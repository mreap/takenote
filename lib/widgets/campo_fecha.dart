import 'package:flutter/material.dart';

import '../app/utils/formato.dart';

/// Campo de solo lectura que abre un selector de fecha y permite borrarla.
class CampoFecha extends StatelessWidget {
  const CampoFecha({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.alCambiar,
    this.textoVacio = 'Sin fecha',
  });

  final String etiqueta;
  final DateTime? valor;
  final ValueChanged<DateTime?> alCambiar;
  final String textoVacio;

  Future<void> _elegir(BuildContext context) async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: valor ?? hoy,
      firstDate: DateTime(2000),
      lastDate: DateTime(hoy.year + 10),
    );
    if (elegida != null) alCambiar(elegida);
  }

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () => _elegir(context),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: const Icon(Icons.event_outlined),
        suffixIcon: valor == null
            ? null
            : IconButton(
                tooltip: 'Quitar fecha',
                icon: const Icon(Icons.clear),
                onPressed: () => alCambiar(null),
              ),
      ),
      child: Text(valor == null ? textoVacio : Formato.fechaCorta(valor!)),
    ),
  );
}
