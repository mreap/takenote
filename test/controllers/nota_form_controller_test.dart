import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:takenote/controllers/nota_form_controller.dart';
import 'package:takenote/data/api_exception.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(registrarFallbacks);
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('NotaFormController', () {
    late MockNotasRepository repo;

    setUp(() => repo = MockNotasRepository());

    test('validaciones', () {
      expect(NotaFormController.validarTitulo('  '), isNotNull);
      expect(NotaFormController.validarTitulo('Hola'), isNull);
      expect(NotaFormController.validarClasificador('dos palabras'), isNotNull);
      expect(NotaFormController.validarClasificador('trabajo'), isNull);
      expect(NotaFormController.validarClasificador(''), isNull);
      expect(NotaFormController.validarValor('12,5'), isNull);
      expect(NotaFormController.leerValor('12,5'), 12.5);
      expect(NotaFormController.validarValor('abc'), isNotNull);
    });

    test('crear envía los datos del formulario', () async {
      when(() => repo.crear(any())).thenAnswer((_) async => nota(id: 3));
      final c = NotaFormController(repo)
        ..titulo.text = ' Comprar pan '
        ..clasificador.text = 'compras'
        ..valor.text = '2,5';
      final resultado = await c.guardar();
      expect(resultado?.id, 3);
      final entrada = verify(() => repo.crear(captureAny())).captured.single;
      expect(entrada.aJsonCrear(), containsPair('titulo', 'Comprar pan'));
      expect(entrada.aJsonCrear(), containsPair('valor', 2.5));
    });

    test('editar sin cambios no llama al servidor', () async {
      final original = nota(id: 4);
      final c = NotaFormController(repo, original: original);
      expect(await c.guardar(), same(original));
      verifyNever(() => repo.actualizar(any(), any()));
    });

    test('un 422 expone los errores por campo', () async {
      when(() => repo.crear(any())).thenThrow(
        const ApiException(
          TipoError.validacion,
          statusCode: 422,
          erroresCampo: {'titulo': 'muy largo'},
        ),
      );
      final c = NotaFormController(repo)..titulo.text = 'x';
      expect(await c.guardar(), isNull);
      expect(c.erroresCampo['titulo'], 'muy largo');
      expect(c.mensajeError.value, isNotNull);
    });

    test('tras un error sin campos se puede seguir editando', () async {
      when(() => repo.crear(any())).thenThrow(errorSinConexion);
      final c = NotaFormController(repo)..titulo.text = 'x';
      expect(await c.guardar(), isNull);
      expect(() => c.erroresCampo.remove('titulo'), returnsNormally);
    });
  });
}
