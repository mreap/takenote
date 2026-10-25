import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:takenote/app/routes/app_pages.dart';
import 'package:takenote/app/routes/app_routes.dart';
import 'package:takenote/app/theme/app_theme.dart';
import 'package:takenote/controllers/auth_controller.dart';
import 'package:takenote/data/api_exception.dart';

import '../helpers/fakes.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() {
    Get.testMode = true;
    repo = MockAuthRepository();
  });

  tearDown(Get.reset);

  Future<void> abrirLogin(WidgetTester tester) async {
    Get.put(AuthController(repo));
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.claro,
        initialRoute: Rutas.login,
        getPages: AppPages.paginas,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> loginFallido(WidgetTester tester) async {
    when(
      () => repo.login(
        correo: any(named: 'correo'),
        clave: any(named: 'clave'),
      ),
    ).thenThrow(const ApiException(TipoError.noAutorizado, statusCode: 401));
    await tester.enterText(find.byType(TextFormField).at(0), 'ana@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'clave-mala');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Correo o clave incorrectos.'), findsOneWidget);
  }

  testWidgets('abrir el registro no modifica estado durante el build', (
    tester,
  ) async {
    await abrirLogin(tester);
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Regístrate para guardar tus notas'), findsOneWidget);
  });

  testWidgets('el error del login no aparece en el registro', (tester) async {
    await abrirLogin(tester);
    await loginFallido(tester);
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    expect(find.text('Correo o clave incorrectos.'), findsNothing);
  });

  testWidgets('volver del registro limpia sus errores', (tester) async {
    await abrirLogin(tester);
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    Get.find<AuthController>().mensajeError.value = 'Error del registro';
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Error del registro'), findsNothing);
    expect(find.text('Inicia sesión para ver tus notas'), findsOneWidget);
  });
}
