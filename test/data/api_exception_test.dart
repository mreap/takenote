import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takenote/data/api_exception.dart';

void main() {
  final peticion = RequestOptions(path: '/notas');

  ApiException deRespuesta(int status, [Object? data]) => ApiException.desdeDio(
    DioException(
      requestOptions: peticion,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: peticion,
        statusCode: status,
        data: data,
      ),
    ),
  );

  ApiException deTipo(DioExceptionType tipo) =>
      ApiException.desdeDio(DioException(requestOptions: peticion, type: tipo));

  group('códigos HTTP', () {
    final casos = {
      400: TipoError.solicitudInvalida,
      401: TipoError.noAutorizado,
      404: TipoError.noEncontrado,
      409: TipoError.conflicto,
      422: TipoError.validacion,
      503: TipoError.iaNoDisponible,
      500: TipoError.servidor,
      502: TipoError.servidor,
    };
    casos.forEach((status, tipo) {
      test('$status -> $tipo', () {
        final e = deRespuesta(status);
        expect(e.tipo, tipo);
        expect(e.statusCode, status);
      });
    });

    test('cada tipo de error tiene un mensaje distinto', () {
      final mensajes = {
        for (final s in [400, 401, 404, 409, 422, 503, 500])
          deRespuesta(s).mensaje,
        deTipo(DioExceptionType.connectionError).mensaje,
        deTipo(DioExceptionType.receiveTimeout).mensaje,
      };
      expect(mensajes, hasLength(9));
    });
  });

  group('errores de red', () {
    test('sin conexión', () {
      expect(
        deTipo(DioExceptionType.connectionError).tipo,
        TipoError.sinConexion,
      );
    });

    test('todos los timeouts se tratan igual', () {
      for (final t in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.transformTimeout,
      ]) {
        expect(deTipo(t).tipo, TipoError.timeout, reason: '$t');
      }
    });
  });

  group('422 de FastAPI', () {
    test('detail como lista se convierte en errores por campo', () {
      final e = deRespuesta(422, {
        'detail': [
          {
            'loc': ['body', 'titulo'],
            'msg': 'String should have at least 1 character',
            'type': 'string_too_short',
          },
          {
            'loc': ['body', 'clave'],
            'msg': 'String should have at least 6 characters',
            'type': 'string_too_short',
          },
        ],
      });
      expect(e.erroresCampo, {
        'titulo': 'String should have at least 1 character',
        'clave': 'String should have at least 6 characters',
      });
      expect(e.mensaje, contains('titulo'));
    });

    test('detail como texto también se acepta', () {
      final e = deRespuesta(422, {'detail': 'Datos inválidos'});
      expect(e.erroresCampo, {'general': 'Datos inválidos'});
    });

    test('loc sin campo va a general', () {
      final e = deRespuesta(422, {
        'detail': [
          {
            'loc': ['body'],
            'msg': 'JSON inválido',
            'type': 'x',
          },
        ],
      });
      expect(e.erroresCampo, {'general': 'JSON inválido'});
    });
  });

  test('detail de texto del servidor se conserva', () {
    final e = deRespuesta(409, {'detail': 'El correo ya está registrado'});
    expect(e.detalleServidor, 'El correo ya está registrado');
  });

  group('convertirRespuesta', () {
    test('un JSON con forma inesperada se vuelve ApiException', () {
      expect(
        () => convertirRespuesta(['no', 'es', 'mapa'], (d) => (d as Map)['x']),
        throwsA(
          isA<ApiException>().having(
            (e) => e.tipo,
            'tipo',
            TipoError.respuestaInvalida,
          ),
        ),
      );
    });

    test('un JSON válido se convierte normalmente', () {
      expect(convertirRespuesta({'x': 1}, (d) => (d as Map)['x']), 1);
    });
  });
}
