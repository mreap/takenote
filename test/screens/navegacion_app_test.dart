import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:takenote/app/routes/app_pages.dart';
import 'package:takenote/app/routes/app_routes.dart';
import 'package:takenote/app/theme/app_theme.dart';
import 'package:takenote/controllers/auth_controller.dart';
import 'package:takenote/models/nota.dart';
import 'package:takenote/models/usuario.dart';
import 'package:takenote/repositories/ia_repository.dart';
import 'package:takenote/repositories/notas_repository.dart';

import '../helpers/fakes.dart';

/// Recorre todas las pantallas con sesión iniciada y verifica que ninguna
/// lance excepciones (por ejemplo, estado modificado durante un build).
void main() {
  setUpAll(registrarFallbacks);
  tearDown(Get.reset);

  testWidgets('recorrido por todas las pantallas sin excepciones', (
    tester,
  ) async {
    Get.testMode = true;
    final notas = MockNotasRepository();
    final n = nota(id: 1, titulo: 'Comprar pan');
    when(
      () => notas.listar(
        filtros: any(named: 'filtros'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => [n]);
    when(() => notas.guardarNotas(any(), any())).thenAnswer((_) async {});
    when(() => notas.obtener(1)).thenAnswer((_) async => n);
    when(
      () => notas.publicas(
        clasificador: any(named: 'clasificador'),
        q: any(named: 'q'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => <NotaPublica>[]);
    Get.put<NotasRepository>(notas);
    Get.put<IaRepository>(MockIaRepository());
    Get.put(AuthController(MockAuthRepository())).usuario.value = const Usuario(
      id: 7,
      correo: 'ana@test.com',
      nombre: 'Ana',
    );

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.claro,
        initialRoute: Rutas.notas,
        getPages: AppPages.paginas,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Comprar pan'), findsOneWidget);

    // Detalle -> formulario de edición -> atrás -> atrás.
    await tester.tap(find.text('Comprar pan'));
    await tester.pumpAndSettle();
    expect(find.text('Asistente IA'), findsOneWidget);
    await tester.tap(find.byTooltip('Editar'));
    await tester.pumpAndSettle();
    expect(find.text('Editar nota'), findsOneWidget);
    Get.back();
    await tester.pumpAndSettle();
    Get.back();
    await tester.pumpAndSettle();

    // Nueva nota.
    await tester.tap(find.text('Nueva nota'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Nueva nota'), findsOneWidget);
    Get.back();
    await tester.pumpAndSettle();

    // Públicas y resumen desde el menú.
    for (final (destino, titulo) in [
      ('Notas públicas', 'Todavía no hay notas públicas'),
      ('Resumen con IA', 'Generar resumen'),
    ]) {
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(destino));
      await tester.pumpAndSettle();
      expect(find.text(titulo), findsOneWidget);
      Get.back();
      await tester.pumpAndSettle();
    }

    expect(tester.takeException(), isNull);
  });
}
