import 'package:get/get.dart';

import '../data/api_exception.dart';
import '../models/ia.dart';
import '../models/nota.dart';
import '../repositories/ia_repository.dart';
import '../repositories/notas_repository.dart';
import 'estado_vista.dart';
import 'notas_controller.dart';

/// Detalle de una nota con acciones rápidas y sugerencia de la IA.
class NotaDetalleController extends GetxController {
  NotaDetalleController(
    this._notas,
    this._ia, {
    required this.notaId,
    Nota? inicial,
  }) : nota = Rxn<Nota>(inicial);

  final NotasRepository _notas;
  final IaRepository _ia;
  final int? notaId;

  final Rxn<Nota> nota;
  final estado = EstadoVista.cargando.obs;
  final mensajeError = ''.obs;
  final procesando = false.obs;

  final sugerencia = Rxn<SugerenciaNota>();
  final estadoIa = EstadoVista.inicial.obs;
  final mensajeErrorIa = ''.obs;

  @override
  void onInit() {
    super.onInit();
    cargar();
  }

  Future<void> cargar() async {
    if (notaId == null) {
      mensajeError.value = 'No se indicó qué nota abrir.';
      estado.value = EstadoVista.error;
      return;
    }
    if (nota.value == null) estado.value = EstadoVista.cargando;
    try {
      _actualizar(await _notas.obtener(notaId!));
      estado.value = EstadoVista.datos;
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      estado.value = EstadoVista.error;
    }
  }

  /// Cambia `revisada`, `prioritaria` o `publica`. Devuelve un error o `null`.
  Future<String?> alternar(String campo) async {
    final actual = nota.value;
    if (actual == null || procesando.value) return null;
    final valor = switch (campo) {
      'revisada' => actual.revisada,
      'prioritaria' => actual.prioritaria,
      'publica' => actual.publica,
      _ => throw ArgumentError.value(campo, 'campo'),
    };
    return _accion(() async {
      _actualizar(await _notas.actualizar(actual.id, {campo: !valor}));
    });
  }

  /// Devuelve un error o `null` si la nota se eliminó.
  Future<String?> eliminar() async {
    final actual = nota.value;
    if (actual == null) return null;
    return _accion(() async {
      await _notas.eliminar(actual.id);
      if (Get.isRegistered<NotasController>()) {
        Get.find<NotasController>().quitar(actual.id);
      }
    });
  }

  Future<void> pedirSugerencia() async {
    final actual = nota.value;
    if (actual == null) return;
    estadoIa.value = EstadoVista.cargando;
    sugerencia.value = null;
    try {
      sugerencia.value = await _ia.sugerencia(actual.id);
      estadoIa.value = EstadoVista.datos;
    } on ApiException catch (e) {
      mensajeErrorIa.value = e.mensaje;
      estadoIa.value = EstadoVista.error;
    }
  }

  /// Aplica la sugerencia en el servidor. Devuelve un error o `null`.
  Future<String?> aplicarSugerencia({required bool cambiarTitulo}) async {
    final actual = nota.value;
    if (actual == null) return null;
    final error = await _accion(() async {
      _actualizar(
        await _ia.aplicarSugerencia(actual.id, cambiarTitulo: cambiarTitulo),
      );
    });
    if (error == null) {
      sugerencia.value = null;
      estadoIa.value = EstadoVista.inicial;
    }
    return error;
  }

  void descartarSugerencia() {
    sugerencia.value = null;
    estadoIa.value = EstadoVista.inicial;
  }

  /// Tras editar en el formulario.
  void reemplazar(Nota actualizada) => _actualizar(actualizada);

  Future<String?> _accion(Future<void> Function() accion) async {
    procesando.value = true;
    try {
      await accion();
      return null;
    } on ApiException catch (e) {
      return e.mensaje;
    } finally {
      procesando.value = false;
    }
  }

  void _actualizar(Nota n) {
    nota.value = n;
    if (Get.isRegistered<NotasController>()) {
      Get.find<NotasController>().reemplazar(n);
    }
  }
}
