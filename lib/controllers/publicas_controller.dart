import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/api_exception.dart';
import '../models/nota.dart';
import '../repositories/notas_repository.dart';
import 'estado_vista.dart';

/// Notas públicas de todos los usuarios.
class PublicasController extends GetxController {
  PublicasController(this._repo);

  static const tamanoPagina = 20;

  final NotasRepository _repo;

  final notas = <NotaPublica>[].obs;
  final estado = EstadoVista.cargando.obs;
  final mensajeError = ''.obs;
  final busqueda = ''.obs;
  final campoBusqueda = TextEditingController();
  final hayMas = false.obs;
  final cargandoMas = false.obs;
  final errorPaginacion = RxnString();

  late final Worker _buscar;
  int _peticion = 0;

  String? get _q =>
      busqueda.value.trim().isEmpty ? null : busqueda.value.trim();

  @override
  void onInit() {
    super.onInit();
    _buscar = debounce(
      busqueda,
      (_) => cargar(),
      time: const Duration(milliseconds: 400),
    );
    cargar();
  }

  @override
  void onClose() {
    _buscar.dispose();
    campoBusqueda.dispose();
    super.onClose();
  }

  Future<void> cargar() async {
    final id = ++_peticion;
    if (notas.isEmpty || estado.value != EstadoVista.datos) {
      estado.value = EstadoVista.cargando;
    }
    errorPaginacion.value = null;
    try {
      final pagina = await _repo.publicas(q: _q, limit: tamanoPagina);
      if (id != _peticion) return;
      notas.assignAll(pagina);
      hayMas.value = pagina.length == tamanoPagina;
      estado.value = pagina.isEmpty ? EstadoVista.vacio : EstadoVista.datos;
    } on ApiException catch (e) {
      if (id != _peticion) return;
      mensajeError.value = e.mensaje;
      notas.clear();
      estado.value = EstadoVista.error;
    }
  }

  Future<void> cargarMas() async {
    if (!hayMas.value || cargandoMas.value) return;
    final id = _peticion;
    cargandoMas.value = true;
    errorPaginacion.value = null;
    try {
      final pagina = await _repo.publicas(
        q: _q,
        limit: tamanoPagina,
        offset: notas.length,
      );
      if (id != _peticion) return;
      notas.addAll(pagina);
      hayMas.value = pagina.length == tamanoPagina;
    } on ApiException catch (e) {
      if (id == _peticion) errorPaginacion.value = e.mensaje;
    } finally {
      cargandoMas.value = false;
    }
  }
}
