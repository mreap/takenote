import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/filtros_notas.dart';
import 'campo_fecha.dart';

/// Hoja inferior para editar los filtros de la lista. Devuelve los filtros
/// elegidos o `null` si se cierra sin aplicar.
Future<FiltrosNotas?> mostrarFiltros(
  BuildContext context,
  FiltrosNotas actuales,
) => showModalBottomSheet<FiltrosNotas>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _FiltrosSheet(actuales),
);

class _FiltrosSheet extends StatefulWidget {
  const _FiltrosSheet(this.actuales);

  final FiltrosNotas actuales;

  @override
  State<_FiltrosSheet> createState() => _FiltrosSheetState();
}

/// El borrador de filtros es estado local de la hoja; usa Rx en lugar de setState.
class _FiltrosSheetState extends State<_FiltrosSheet> {
  late final _clasificador = TextEditingController(
    text: widget.actuales.clasificador,
  );
  late final _revisada = Rxn<bool>(widget.actuales.revisada);
  late final _prioritaria = Rxn<bool>(widget.actuales.prioritaria);
  late final _desde = Rxn<DateTime>(widget.actuales.desde);
  late final _hasta = Rxn<DateTime>(widget.actuales.hasta);

  String? get _errorRango {
    final d = _desde.value, h = _hasta.value;
    return d != null && h != null && d.isAfter(h)
        ? '"Desde" no puede ser posterior a "Hasta".'
        : null;
  }

  @override
  void dispose() {
    _clasificador.dispose();
    super.dispose();
  }

  void _aplicar() {
    final c = _clasificador.text.trim();
    Navigator.of(context).pop(
      FiltrosNotas(
        clasificador: c.isEmpty ? null : c,
        revisada: _revisada.value,
        prioritaria: _prioritaria.value,
        q: widget.actuales.q,
        desde: _desde.value,
        hasta: _hasta.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filtrar notas', style: tema.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _clasificador,
              decoration: const InputDecoration(
                labelText: 'Clasificador',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 16),
            Text('Estado', style: tema.textTheme.labelLarge),
            const SizedBox(height: 8),
            Obx(
              () => _Tres(
                valor: _revisada.value,
                alCambiar: (v) => _revisada.value = v,
                textoSi: 'Revisadas',
                textoNo: 'Pendientes',
              ),
            ),
            const SizedBox(height: 16),
            Text('Prioridad', style: tema.textTheme.labelLarge),
            const SizedBox(height: 8),
            Obx(
              () => _Tres(
                valor: _prioritaria.value,
                alCambiar: (v) => _prioritaria.value = v,
                textoSi: 'Prioritarias',
                textoNo: 'Normales',
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: CampoFecha(
                      etiqueta: 'Desde',
                      valor: _desde.value,
                      alCambiar: (f) => _desde.value = f,
                      textoVacio: 'Cualquiera',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CampoFecha(
                      etiqueta: 'Hasta',
                      valor: _hasta.value,
                      alCambiar: (f) => _hasta.value = f,
                      textoVacio: 'Cualquiera',
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => _errorRango == null
                  ? const SizedBox(height: 24)
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _errorRango!,
                        style: TextStyle(color: tema.colorScheme.error),
                      ),
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context)
                            .pop(FiltrosNotas(q: widget.actuales.q)),
                    child: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => FilledButton(
                      onPressed: _errorRango == null ? _aplicar : null,
                      child: const Text('Aplicar'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Selector Todas / Sí / No para un filtro booleano opcional.
class _Tres extends StatelessWidget {
  const _Tres({
    required this.valor,
    required this.alCambiar,
    required this.textoSi,
    required this.textoNo,
  });

  final bool? valor;
  final ValueChanged<bool?> alCambiar;
  final String textoSi;
  final String textoNo;

  @override
  Widget build(BuildContext context) => SegmentedButton<int>(
    showSelectedIcon: false,
    segments: [
      const ButtonSegment(value: 0, label: Text('Todas')),
      ButtonSegment(value: 1, label: Text(textoNo)),
      ButtonSegment(value: 2, label: Text(textoSi)),
    ],
    selected: {valor == null ? 0 : (valor! ? 2 : 1)},
    onSelectionChanged: (s) => alCambiar(switch (s.first) {
      1 => false,
      2 => true,
      _ => null,
    }),
  );
}
