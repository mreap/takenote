import 'package:dio/dio.dart';

enum TipoError {
  sinConexion,
  timeout,
  solicitudInvalida,
  noAutorizado,
  noEncontrado,
  conflicto,
  validacion,
  iaNoDisponible,
  servidor,
  respuestaInvalida,
  desconocido,
}

/// Único tipo de error que sale de la capa `data`. Controladores y pantallas
/// nunca ven `DioException`.
class ApiException implements Exception {
  const ApiException(
    this.tipo, {
    this.statusCode,
    this.detalleServidor,
    this.erroresCampo = const {},
  });

  final TipoError tipo;
  final int? statusCode;

  /// `detail` del servidor cuando es un texto.
  final String? detalleServidor;

  /// Errores 422 por campo (`titulo` -> mensaje). Los que no tienen campo
  /// van bajo la clave `general`.
  final Map<String, String> erroresCampo;

  factory ApiException.desdeDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(TipoError.timeout);
      case DioExceptionType.connectionError:
        return const ApiException(TipoError.sinConexion);
      case DioExceptionType.badResponse:
        final r = e.response;
        return ApiException.desdeRespuesta(r?.statusCode ?? 0, r?.data);
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return const ApiException(TipoError.desconocido);
    }
  }

  factory ApiException.desdeRespuesta(int status, dynamic data) {
    final detail = data is Map ? data['detail'] : null;
    final detalleTexto = detail is String ? detail : null;
    final tipo = switch (status) {
      400 => TipoError.solicitudInvalida,
      401 || 403 => TipoError.noAutorizado,
      404 => TipoError.noEncontrado,
      409 => TipoError.conflicto,
      422 => TipoError.validacion,
      503 => TipoError.iaNoDisponible,
      >= 500 => TipoError.servidor,
      _ => TipoError.desconocido,
    };
    return ApiException(
      tipo,
      statusCode: status,
      detalleServidor: detalleTexto,
      erroresCampo: tipo == TipoError.validacion
          ? _erroresValidacion(detail)
          : const {},
    );
  }

  /// FastAPI devuelve `detail` como lista de `{loc, msg, type}`; se tolera
  /// también un texto simple.
  static Map<String, String> _erroresValidacion(dynamic detail) {
    if (detail is String) return {'general': detail};
    if (detail is! List) return const {};
    final errores = <String, String>{};
    for (final item in detail) {
      if (item is! Map) continue;
      final loc = item['loc'];
      final campo = loc is List && loc.length > 1 ? '${loc.last}' : 'general';
      errores.putIfAbsent(campo, () => '${item['msg'] ?? 'valor no válido'}');
    }
    return errores;
  }

  String get mensaje => switch (tipo) {
    TipoError.sinConexion =>
      'Sin conexión. Revisa tu acceso a internet e inténtalo de nuevo.',
    TipoError.timeout =>
      'El servidor tardó demasiado en responder. Inténtalo de nuevo.',
    TipoError.solicitudInvalida =>
      'La solicitud no es válida${_sufijo(detalleServidor)}.',
    TipoError.noAutorizado =>
      'Tu sesión no es válida o expiró. Inicia sesión de nuevo.',
    TipoError.noEncontrado => 'La nota no existe o no tienes acceso a ella.',
    TipoError.conflicto => 'El recurso ya existe${_sufijo(detalleServidor)}.',
    TipoError.validacion =>
      erroresCampo.isEmpty
          ? 'Hay datos no válidos.'
          : 'Revisa los datos: ${erroresCampo.entries.map((e) => e.key == 'general' ? e.value : '${e.key}: ${e.value}').join('; ')}.',
    TipoError.iaNoDisponible => 'El asistente de IA no está disponible en este momento. Inténtalo más tarde.',
    TipoError.servidor =>
      'Error del servidor (${statusCode ?? '5xx'}). Inténtalo más tarde.',
    TipoError.respuestaInvalida =>
      'El servidor respondió con datos inesperados. Inténtalo más tarde.',
    TipoError.desconocido => 'Ocurrió un error inesperado. Inténtalo de nuevo.',
  };

  static String _sufijo(String? detalle) =>
      detalle == null || detalle.isEmpty ? '' : ': $detalle';

  @override
  String toString() => 'ApiException($tipo, $statusCode): $mensaje';
}

/// Convierte la respuesta con [conversor]. Si el JSON no tiene la forma del
/// contrato lanza [ApiException] en vez de dejar escapar un `TypeError`, que
/// dejaría la pantalla cargando para siempre.
T convertirRespuesta<T>(Object? datos, T Function(Object? datos) conversor) {
  try {
    return conversor(datos);
  } on TypeError {
    throw const ApiException(TipoError.respuestaInvalida);
  } on FormatException {
    throw const ApiException(TipoError.respuestaInvalida);
  }
}
