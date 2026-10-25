/// Configuración de entorno. La URL base se puede cambiar al compilar con
/// `--dart-define=API_BASE_URL=...`; no hay secretos en la app.
class Env {
  Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://gestiontotal.info/takenote',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Las llamadas de IA esperan la respuesta del modelo en el servidor.
  static const Duration receiveTimeoutIa = Duration(seconds: 60);

  /// Certificados que completan la cadena TLS de gestiontotal.info, que no
  /// envía su intermedio (ver CLAUDE.md).
  static const List<String> certificadosExtra = [
    'assets/certs/ssl_com_tls_issuing_rsa_r1.pem',
    'assets/certs/ssl_com_tls_rsa_root_2022.pem',
  ];
}
