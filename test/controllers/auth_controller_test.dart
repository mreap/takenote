import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:takenote/controllers/auth_controller.dart';
import 'package:takenote/data/api_exception.dart';
import 'package:takenote/models/usuario.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(registrarFallbacks);
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('AuthController', () {
    late MockAuthRepository repo;
    late AuthController c;
    const ana = Usuario(id: 7, correo: 'ana@test.com', nombre: 'Ana');

    setUp(() {
      repo = MockAuthRepository();
      c = AuthController(repo);
    });

    test('login correcto guarda el usuario', () async {
      when(() => repo.login(correo: 'ana@test.com', clave: 'secreta'))
          .thenAnswer((_) async => ana);
      expect(await c.login(' ana@test.com ', 'secreta'), isTrue);
      expect(c.usuario.value?.nombre, 'Ana');
      expect(c.cargando.value, isFalse);
    });

    test('login con 401 muestra "credenciales incorrectas"', () async {
      when(
        () => repo.login(
          correo: any(named: 'correo'),
          clave: any(named: 'clave'),
        ),
      ).thenThrow(const ApiException(TipoError.noAutorizado, statusCode: 401));
      expect(await c.login('a@b.com', 'x'), isFalse);
      expect(c.mensajeError.value, 'Correo o clave incorrectos.');
    });

    test('registro con 409 indica que el correo existe', () async {
      when(
        () => repo.registrar(
          correo: any(named: 'correo'),
          nombre: any(named: 'nombre'),
          clave: any(named: 'clave'),
        ),
      ).thenThrow(const ApiException(TipoError.conflicto, statusCode: 409));
      expect(await c.registrar('Ana', 'a@b.com', '123456'), isFalse);
      expect(c.mensajeError.value, contains('ya está registrado'));
    });

    test('restaurar sin token va a login', () async {
      when(() => repo.tieneToken()).thenAnswer((_) async => false);
      expect(await c.restaurarSesion(), ResultadoSesion.sinSesion);
    });

    test('restaurar con token inválido borra la sesión', () async {
      when(() => repo.tieneToken()).thenAnswer((_) async => true);
      when(
        () => repo.perfil(),
      ).thenThrow(const ApiException(TipoError.noAutorizado, statusCode: 401));
      when(() => repo.cerrarSesion()).thenAnswer((_) async {});
      expect(await c.restaurarSesion(), ResultadoSesion.sinSesion);
      verify(() => repo.cerrarSesion()).called(1);
    });

    test('restaurar sin conexión entra con el último usuario', () async {
      when(() => repo.tieneToken()).thenAnswer((_) async => true);
      when(() => repo.perfil()).thenThrow(errorSinConexion);
      when(() => repo.usuarioGuardado()).thenReturn(ana);
      expect(await c.restaurarSesion(), ResultadoSesion.autenticado);
      expect(c.usuario.value?.id, 7);
    });
  });
}
