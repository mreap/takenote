import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/api_exception.dart';
import '../models/filtros_notas.dart';
import '../models/nota.dart';
import '../repositories/notas_repository.dart';
import 'estado_vista.dart';

/// Lista de notas del usuario con filtros, búsqueda y paginación.
class NotasController extends GetxController {
  NotasController(this._repo, {required this.usuarioId});

  static const tamanoPagina = 20;

  final NotasRepository _repo;
  final int? usuarioId;

  final notas = <Nota>[].obs;
  final estado = EstadoVista.cargando.obs;
  final mensajeError = ''.obs;
  final filtros = const FiltrosNotas().obs;
  final busqueda = ''.obs;
  final campoBusqueda = TextEditingController();
  final hayMas = false.obs;
  final cargandoMas = false.obs;
  final errorPaginacion = RxnString();

  /// La lista viene de la copia local porque no hubo conexión.
  final mostrandoCopiaLocal = false.obs;

  late final Worker _buscar;

  /// Solo se aplica la respuesta de la petición más reciente.
  int _peticion = 0;

  FiltrosNotas get _filtrosEfectivos =>
      filtros.value.conBusqueda(busqueda.value);

  bool get hayFiltros => !_filtrosEfectivos.vacio;

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
    final f = _filtrosEfectivos;
    if (notas.isEmpty || estado.value != EstadoVista.datos) {
      estado.value = EstadoVista.cargando;
    }
    errorPaginacion.value = null;
    try {
      final pagina = await _repo.listar(filtros: f, limit: tamanoPagina);
      if (id != _peticion) return;
      notas.assignAll(pagina);
      hayMas.value = pagina.length == tamanoPagina;
      mostrandoCopiaLocal.value = false;
      estado.value = pagina.isEmpty ? EstadoVista.vacio : EstadoVista.datos;
      if (f.vacio && usuarioId != null) {
        await _repo.guardarNotas(usuarioId!, pagina);
      }
    } on ApiException catch (e) {
      if (id != _peticion) return;
      mensajeError.value = e.mensaje;
      if (_usarCopiaLocal(e, f)) return;
      notas.clear();
      estado.value = EstadoVista.error;
    }
  }

  bool _usarCopiaLocal(ApiException e, FiltrosNotas f) {
    final sinRed =
        e.tipo == TipoError.sinConexion || e.tipo == TipoError.timeout;
    if (!sinRed || !f.vacio || usuarioId == null) return false;
    final copia = _repo.notasGuardadas(usuarioId!);
    if (copia == null || copia.isEmpty) return false;
    notas.assignAll(copia);
    hayMas.value = false;
    mostrandoCopiaLocal.value = true;
    estado.value = EstadoVista.datos;
    return true;
  }

  Future<void> cargarMas() async {
    if (!hayMas.value || cargandoMas.value || mostrandoCopiaLocal.value) return;
    final id = _peticion;
    cargandoMas.value = true;
    errorPaginacion.value = null;
    try {
      final pagina = await _repo.listar(
        filtros: _filtrosEfectivos,
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

  void aplicarFiltros(FiltrosNotas nuevos) {
    filtros.value = nuevos;
    cargar();
  }

  void limpiarFiltros() {
    filtros.value = const FiltrosNotas();
    campoBusqueda.clear();
    busqueda.value = '';
    cargar();
  }

  /// Invierte `revisada`. Devuelve un mensaje de error o `null` si salió bien.
  Future<String?> alternarRevisada(Nota nota) async {
    try {
      reemplazar(await _repo.actualizar(nota.id, {'revisada': !nota.revisada}));
      return null;
    } on ApiException catch (e) {
      return e.mensaje;
    }
  }

  /// Quita la nota de inmediato y la repone si el servidor falla. Devuelve un
  /// mensaje de error o `null` si se eliminó.
  Future<String?> eliminar(Nota nota) async {
    final i = notas.indexWhere((n) => n.id == nota.id);
    quitar(nota.id);
    try {
      await _repo.eliminar(nota.id);
      return null;
    } on ApiException catch (e) {
      if (i >= 0) notas.insert(i.clamp(0, notas.length), nota);
      estado.value = EstadoVista.datos;
      return e.mensaje;
    }
  }

  // Sincronización con detalle y formulario.

  void agregar(Nota nota) {
    notas.insert(0, nota);
    estado.value = EstadoVista.datos;
  }

  void reemplazar(Nota nota) {
    final i = notas.indexWhere((n) => n.id == nota.id);
    if (i >= 0) notas[i] = nota;
  }

  void quitar(int id) {
    notas.removeWhere((n) => n.id == id);
    if (notas.isEmpty) estado.value = EstadoVista.vacio;
  }
}
