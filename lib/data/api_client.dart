import 'package:dio/dio.dart';

import '../app/config/env.dart';
import 'api_exception.dart';
import 'tls/certificados.dart';
import 'token_storage.dart';

/// Único punto de la app que hace HTTP. Agrega el token Bearer, aplica los
/// timeouts y convierte todo error en [ApiException].
class ApiClient {
  ApiClient({
    required this._tokenStorage,
    Dio? dio,
    List<List<int>> certificadosExtra = const [],
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: Env.apiBaseUrl,
               connectTimeout: Env.connectTimeout,
               receiveTimeout: Env.receiveTimeout,
               sendTimeout: Env.connectTimeout,
               contentType: Headers.jsonContentType,
               responseType: ResponseType.json,
             ),
           ) {
    configurarCertificados(_dio, certificadosExtra);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _agregarToken,
        onError: _detectarExpiracion,
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  /// Se invoca cuando una petición autenticada recibe 401 (token expirado o
  /// inválido). Un 401 de login no la dispara porque no lleva token.
  void Function()? alExpirarSesion;

  static const _sinToken = 'sinToken';

  Future<void> _agregarToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[_sinToken] != true) {
      final token = await _tokenStorage.leer();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  void _detectarExpiracion(DioException e, ErrorInterceptorHandler handler) {
    if (e.response?.statusCode == 401 &&
        e.requestOptions.headers.containsKey('Authorization')) {
      alExpirarSesion?.call();
    }
    handler.next(e);
  }

  Future<dynamic> get(String ruta, {Map<String, dynamic>? query}) =>
      _ejecutar(() => _dio.get(ruta, queryParameters: _limpiar(query)));

  Future<dynamic> post(
    String ruta, {
    Object? datos,
    Map<String, dynamic>? query,
    bool sinToken = false,
    Duration? receiveTimeout,
  }) => _ejecutar(
    () => _dio.post(
      ruta,
      data: datos,
      queryParameters: _limpiar(query),
      options: Options(
        extra: {_sinToken: sinToken},
        receiveTimeout: receiveTimeout,
      ),
    ),
  );

  Future<dynamic> patch(String ruta, {Object? datos}) =>
      _ejecutar(() => _dio.patch(ruta, data: datos));

  Future<void> delete(String ruta) => _ejecutar(() => _dio.delete(ruta));

  Future<dynamic> _ejecutar(
    Future<Response<dynamic>> Function() peticion,
  ) async {
    try {
      final respuesta = await peticion();
      return respuesta.data;
    } on DioException catch (e) {
      throw ApiException.desdeDio(e);
    }
  }

  /// Quita los parámetros nulos o vacíos para no enviar filtros vacíos.
  static Map<String, dynamic>? _limpiar(Map<String, dynamic>? query) {
    if (query == null) return null;
    return Map.of(query)
      ..removeWhere((_, v) => v == null || (v is String && v.trim().isEmpty));
  }
}
