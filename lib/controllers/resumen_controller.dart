import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/api_exception.dart';
import '../models/ia.dart';
import '../repositories/ia_repository.dart';
import 'estado_vista.dart';

/// Resumen de notas generado por la IA del servidor.
class ResumenController extends GetxController {
  ResumenController(this._ia);

  final IaRepository _ia;

  final clasificador = TextEditingController();
  final desde = Rxn<DateTime>();
  final hasta = Rxn<DateTime>();
  final soloPendientes = true.obs;

  final estado = EstadoVista.inicial.obs;
  final resultado = Rxn<ResumenNotas>();
  final mensajeError = ''.obs;

  /// Valida el rango antes de llamar al servidor.
  String? get errorRango {
    final d = desde.value, h = hasta.value;
    return d != null && h != null && d.isAfter(h)
        ? 'La fecha "desde" no puede ser posterior a "hasta".'
        : null;
  }

  Future<void> generar() async {
    if (errorRango != null || estado.value == EstadoVista.cargando) return;
    estado.value = EstadoVista.cargando;
    final texto = clasificador.text.trim();
    try {
      final r = await _ia.resumen(
        desde: desde.value,
        hasta: hasta.value,
        clasificador: texto.isEmpty ? null : texto,
        soloPendientes: soloPendientes.value,
      );
      resultado.value = r;
      estado.value = r.totalNotas == 0 ? EstadoVista.vacio : EstadoVista.datos;
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      estado.value = EstadoVista.error;
    }
  }

  @override
  void onClose() {
    clasificador.dispose();
    super.onClose();
  }
}
