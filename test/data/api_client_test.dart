import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:takenote/data/api_client.dart';
import 'package:takenote/data/api_exception.dart';

import '../helpers/fakes.dart';

/// Adaptador HTTP falso: registra la petición y responde lo configurado.
class AdaptadorFalso implements HttpClientAdapter {
  AdaptadorFalso(this.status, [this.cuerpo]);

  final int status;
  final Object? cuerpo;
  RequestOptions? ultima;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    ultima = options;
    return ResponseBody.fromString(
      cuerpo == null ? '' : jsonEncode(cuerpo),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MockTokenStorage tokens;

  setUp(() {
    tokens = MockTokenStorage();
    when(() => tokens.leer()).thenAnswer((_) async => 'abc123');
  });

  ApiClient cliente(AdaptadorFalso adaptador) {
    final dio = Dio(BaseOptions(baseUrl: 'https://servidor.test/takenote'))
      ..httpClientAdapter = adaptador;
    return ApiClient(tokenStorage: tokens, dio: dio);
  }

  test('respeta el prefijo /takenote de la URL base', () async {
    final a = AdaptadorFalso(200, []);
    await cliente(a).get('/notas');
    expect(a.ultima!.uri.toString(), 'https://servidor.test/takenote/notas');
  });

  test('envía el token Bearer', () async {
    final a = AdaptadorFalso(200, []);
    await cliente(a).get('/notas');
    expect(a.ultima!.headers['Authorization'], 'Bearer abc123');
  });

  test('login y registro no envían token', () async {
    final a = AdaptadorFalso(200, {});
    await cliente(a).post('/auth/login', datos: {}, sinToken: true);
    expect(a.ultima!.headers.containsKey('Authorization'), isFalse);
  });

  test('quita los filtros nulos o vacíos de la query', () async {
    final a = AdaptadorFalso(200, []);
    await cliente(a).get(
      '/notas',
      query: {'q': '  ', 'clasificador': null, 'revisada': false, 'limit': 20},
    );
    expect(a.ultima!.queryParameters, {'revisada': false, 'limit': 20});
  });

  test('un 401 con token avisa que la sesión expiró', () async {
    var expiro = false;
    final c = cliente(AdaptadorFalso(401, {'detail': 'Token inválido'}))
      ..alExpirarSesion = () => expiro = true;
    await expectLater(
      c.get('/notas'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.tipo,
          'tipo',
          TipoError.noAutorizado,
        ),
      ),
    );
    expect(expiro, isTrue);
  });

  test('un 401 de login (sin token) no cierra la sesión', () async {
    var expiro = false;
    final c = cliente(AdaptadorFalso(401, {'detail': 'Credenciales inválidas'}))
      ..alExpirarSesion = () => expiro = true;
    await expectLater(
      c.post('/auth/login', datos: {}, sinToken: true),
      throwsA(isA<ApiException>()),
    );
    expect(expiro, isFalse);
  });

  test('sin token guardado no se envía Authorization', () async {
    when(() => tokens.leer()).thenAnswer((_) async => null);
    final a = AdaptadorFalso(200, []);
    await cliente(a).get('/notas/publicas');
    expect(a.ultima!.headers.containsKey('Authorization'), isFalse);
  });
}
