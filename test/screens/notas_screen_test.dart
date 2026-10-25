import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:takenote/app/theme/app_theme.dart';
import 'package:takenote/controllers/auth_controller.dart';
import 'package:takenote/controllers/notas_controller.dart';
import 'package:takenote/data/api_exception.dart';
import 'package:takenote/models/nota.dart';
import 'package:takenote/screens/notas/notas_screen.dart';

import '../helpers/fakes.dart';

void main() {
  late MockNotasRepository repo;
  late Completer<List<Nota>> respuesta;

  setUpAll(registrarFallbacks);

  setUp(() {
    Get.testMode = true;
    repo = MockNotasRepository();
    when(
      () => repo.listar(
        filtros: any(named: 'filtros'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) => respuesta.future);
    when(() => repo.guardarNotas(any(), any())).thenAnswer((_) async {});
    when(() => repo.notasGuardadas(any())).thenReturn(null);
  });

  tearDown(Get.reset);

  /// El controlador y la respuesta se crean dentro del test para que la carga
  /// inicial corra en la zona de tiempo simulado del tester.
  Future<void> abrir(WidgetTester tester) {
    respuesta = Completer();
    Get.put(AuthController(MockAuthRepository()));
    Get.put(NotasController(repo, usuarioId: 7));
    return tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.claro, home: const NotasScreen()),
    );
  }

  testWidgets('muestra el indicador mientras carga', (tester) async {
    await abrir(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    respuesta.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('muestra el estado vacío con acción para crear', (tester) async {
    await abrir(tester);
    respuesta.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('Aún no tienes notas'), findsOneWidget);
    expect(find.text('Crear nota'), findsOneWidget);
  });

  testWidgets('muestra el error con botón Reintentar', (tester) async {
    await abrir(tester);
    respuesta.completeError(const ApiException(TipoError.timeout));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo cargar'), findsOneWidget);
    expect(find.textContaining('tardó demasiado'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('muestra las notas', (tester) async {
    await abrir(tester);
    respuesta.complete([nota(id: 1, titulo: 'Llamar al banco')]);
    await tester.pumpAndSettle();
    expect(find.text('Llamar al banco'), findsOneWidget);
  });

  testWidgets('la lista se actualiza al agregar una nota', (tester) async {
    await abrir(tester);
    respuesta.complete([nota(id: 1, titulo: 'Primera')]);
    await tester.pumpAndSettle();
    Get.find<NotasController>().agregar(nota(id: 2, titulo: 'Segunda'));
    await tester.pump();
    expect(find.text('Segunda'), findsOneWidget);
  });
}
