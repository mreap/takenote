import 'package:intl/intl.dart';

/// Formatos de fecha y número compartidos por toda la app.
class Formato {
  Formato._();

  static final _api = DateFormat('yyyy-MM-dd');
  static final _corta = DateFormat('dd/MM/yyyy');
  static final _conHora = DateFormat('dd/MM/yyyy HH:mm');
  static final _valor = NumberFormat('#,##0.00');

  /// Fecha `date` del contrato: `yyyy-MM-dd`.
  static String fechaApi(DateTime fecha) => _api.format(fecha);

  static DateTime? leerFechaApi(dynamic valor) =>
      valor is String ? DateTime.tryParse(valor) : null;

  static String fechaCorta(DateTime fecha) => _corta.format(fecha);
  static String fechaHora(DateTime fecha) => _conHora.format(fecha.toLocal());
  static String valor(double valor) => _valor.format(valor);
}
