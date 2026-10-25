import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Agrega certificados de confianza a los del sistema para completar la cadena
/// TLS del servidor. La verificación sigue activa: solo se suma confianza.
void configurarCertificados(Dio dio, List<List<int>> certificadosPem) {
  if (certificadosPem.isEmpty) return;
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final contexto = SecurityContext(withTrustedRoots: true);
      for (final pem in certificadosPem) {
        try {
          contexto.setTrustedCertificatesBytes(pem);
        } on TlsException {
          // Ya estaba entre los certificados del sistema.
        }
      }
      return HttpClient(context: contexto);
    },
  );
}
