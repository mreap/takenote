import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/api_exception.dart';
import '../models/nota.dart';
import '../models/nota_entrada.dart';
import '../repositories/notas_repository.dart';
import 'nota_detalle_controller.dart';
import 'notas_controller.dart';

/// Formulario para crear o editar una nota.
class NotaFormController extends GetxController {
  NotaFormController(this._repo, {this.original});

  final NotasRepository _repo;
  final Nota? original;

  bool get editando => original != null;

  late final titulo = TextEditingController(text: original?.titulo);
  late final clasificador = TextEditingController(text: original?.clasificador);
  late final descripcion = TextEditingController(text: original?.descripcion);
  late final valor = TextEditingController(
    text: original?.valor?.toString() ?? '',
  );
  late final fechaNota = Rxn<DateTime>(original?.fechaNota);
  late final revisada = (original?.revisada ?? false).obs;
  late final prioritaria = (original?.prioritaria ?? false).obs;
  late final publica = (original?.publica ?? false).obs;

  final guardando = false.obs;
  final mensajeError = RxnString();
  final erroresCampo = <String, String>{}.obs;

  static String? validarTitulo(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'El título es obligatorio.';
    if (t.length > 200) return 'Máximo 200 caracteres.';
    return null;
  }

  /// El clasificador es opcional, pero debe ser una sola palabra.
  static String? validarClasificador(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    if (RegExp(r'\s').hasMatch(t)) return 'Usa una sola palabra, sin espacios.';
    return null;
  }

  static String? validarValor(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    return leerValor(t) == null
        ? 'Ingresa un número válido (ej. 12.50).'
        : null;
  }

  /// Acepta coma o punto decimal.
  static double? leerValor(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  NotaEntrada _entrada() {
    String? opcional(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    return NotaEntrada(
      titulo: titulo.text.trim(),
      clasificador: opcional(clasificador),
      descripcion: opcional(descripcion),
      fechaNota: fechaNota.value,
      valor: valor.text.trim().isEmpty ? null : leerValor(valor.text),
      revisada: revisada.value,
      prioritaria: prioritaria.value,
      publica: publica.value,
    );
  }

  /// Guarda y devuelve la nota resultante, o `null` si hubo error (queda en
  /// [mensajeError] y [erroresCampo]).
  Future<Nota?> guardar() async {
    if (guardando.value) return null;
    guardando.value = true;
    mensajeError.value = null;
    erroresCampo.clear();
    try {
      final entrada = _entrada();
      final Nota resultado;
      if (original case final o?) {
        final cambios = entrada.aJsonActualizar(o);
        resultado = cambios.isEmpty ? o : await _repo.actualizar(o.id, cambios);
      } else {
        resultado = await _repo.crear(entrada);
      }
      _sincronizar(resultado);
      return resultado;
    } on ApiException catch (e) {
      // No usar RxMap.assignAll: guarda la referencia (aquí un mapa const).
      erroresCampo
        ..clear()
        ..addAll(e.erroresCampo);
      mensajeError.value = e.mensaje;
      return null;
    } finally {
      guardando.value = false;
    }
  }

  void _sincronizar(Nota nota) {
    if (Get.isRegistered<NotasController>()) {
      final lista = Get.find<NotasController>();
      editando ? lista.reemplazar(nota) : lista.agregar(nota);
    }
    if (editando && Get.isRegistered<NotaDetalleController>()) {
      Get.find<NotaDetalleController>().reemplazar(nota);
    }
  }

  @override
  void onClose() {
    titulo.dispose();
    clasificador.dispose();
    descripcion.dispose();
    valor.dispose();
    super.onClose();
  }
}
