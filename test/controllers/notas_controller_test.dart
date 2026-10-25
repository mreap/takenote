import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:takenote/controllers/estado_vista.dart';
import 'package:takenote/controllers/notas_controller.dart';
import 'package:takenote/data/api_exception.dart';
import 'package:takenote/models/nota.dart';

import '../helpers/fakes.dart';

void main() {
  late MockNotasRepository repo;

  setUpAll(registrarFallbacks);

  setUp(() {
    Get.testMode = true;
    repo = MockNotasRepository();
    when(() => repo.guardarNotas(any(), any())).thenAnswer((_) async {});
  });

  tearDown(Get.reset);

  void responder(Future<List<Nota>> Function() respuesta) {
    when(
      () => repo.listar(
        filtros: any(named: 'filtros'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) => respuesta());
  }

  NotasController crear() => Get.put(NotasController(repo, usuarioId: 7));

  test('con notas pasa a datos y guarda la copia local', () async {
    responder(() async => [nota()]);
    final c = crear();
    expect(c.estado.value, EstadoVista.cargando);
    await pumpEventQueue();
    expect(c.estado.value, EstadoVista.datos);
    expect(c.notas, hasLength(1));
    verify(() => repo.guardarNotas(7, any())).called(1);
  });

  test('sin notas pasa a vacío', () async {
    responder(() async => []);
    final c = crear();
    await pumpEventQueue();
    expect(c.estado.value, EstadoVista.vacio);
  });

  test('un error del servidor pasa a error con su mensaje', () async {
    responder(
      () async => throw const ApiException(TipoError.servidor, statusCode: 500),
    );
    final c = crear();
    await pumpEventQueue();
    expect(c.estado.value, EstadoVista.error);
    expect(c.mensajeError.value, contains('500'));
  });

  test('sin conexión muestra la copia local si existe', () async {
    responder(() async => throw errorSinConexion);
    when(() => repo.notasGuardadas(7)).thenReturn([nota(id: 9)]);
    final c = crear();
    await pumpEventQueue();
    expect(c.estado.value, EstadoVista.datos);
    expect(c.mostrandoCopiaLocal.value, isTrue);
    expect(c.notas.single.id, 9);
  });

  test('sin conexión y sin copia local pasa a error', () async {
    responder(() async => throw errorSinConexion);
    when(() => repo.notasGuardadas(7)).thenReturn(null);
    final c = crear();
    await pumpEventQueue();
    expect(c.estado.value, EstadoVista.error);
  });

  test('eliminar repone la nota si el servidor falla', () async {
    responder(() async => [nota(id: 1), nota(id: 2)]);
    when(() => repo.eliminar(2))
        .thenThrow(const ApiException(TipoError.noEncontrado, statusCode: 404));
    final c = crear();
    await pumpEventQueue();
    final error = await c.eliminar(c.notas[1]);
    expect(error, isNotNull);
    expect(c.notas.map((n) => n.id), [1, 2]);
  });

  test('alternar revisada reemplaza la nota con la respuesta', () async {
    responder(() async => [nota(id: 1)]);
    when(() => repo.actualizar(1, {'revisada': true}))
        .thenAnswer((_) async => nota(id: 1, revisada: true));
    final c = crear();
    await pumpEventQueue();
    expect(await c.alternarRevisada(c.notas.first), isNull);
    expect(c.notas.first.revisada, isTrue);
  });
}
