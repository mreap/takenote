import '../app/config/env.dart';
import '../app/utils/formato.dart';
import '../data/api_client.dart';
import '../data/api_exception.dart';
import '../models/ia.dart';
import '../models/nota.dart';

/// Funciones de IA. El servidor llama al modelo; la app no tiene claves.
class IaRepository {
  IaRepository(this._api);

  final ApiClient _api;

  Future<SugerenciaNota> sugerencia(int notaId) async {
    final datos = await _api.post(
      '/ia/notas/$notaId/sugerencia',
      receiveTimeout: Env.receiveTimeoutIa,
    );
    return convertirRespuesta(
      datos,
      (d) => SugerenciaNota.fromJson(d as Map<String, dynamic>),
    );
  }

  Future<Nota> aplicarSugerencia(
    int notaId, {
    required bool cambiarTitulo,
  }) async {
    final datos = await _api.post(
      '/ia/notas/$notaId/sugerencia/aplicar',
      query: {'cambiar_titulo': cambiarTitulo},
      receiveTimeout: Env.receiveTimeoutIa,
    );
    return convertirRespuesta(
      datos,
      (d) => Nota.fromJson(d as Map<String, dynamic>),
    );
  }

  Future<ResumenNotas> resumen({
    DateTime? desde,
    DateTime? hasta,
    String? clasificador,
    bool soloPendientes = true,
  }) async {
    final datos = await _api.post(
      '/ia/resumen',
      datos: {
        if (desde != null) 'desde': Formato.fechaApi(desde),
        if (hasta != null) 'hasta': Formato.fechaApi(hasta),
        'clasificador': ?clasificador,
        'solo_pendientes': soloPendientes,
      },
      receiveTimeout: Env.receiveTimeoutIa,
    );
    return convertirRespuesta(
      datos,
      (d) => ResumenNotas.fromJson(d as Map<String, dynamic>),
    );
  }
}
