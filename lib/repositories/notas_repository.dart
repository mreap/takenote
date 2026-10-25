import '../data/api_client.dart';
import '../data/api_exception.dart';
import '../data/local_cache.dart';
import '../models/filtros_notas.dart';
import '../models/nota.dart';
import '../models/nota_entrada.dart';

class NotasRepository {
  NotasRepository(this._api, this._cache);

  final ApiClient _api;
  final LocalCache _cache;

  Future<List<Nota>> listar({
    FiltrosNotas filtros = const FiltrosNotas(),
    int limit = 20,
    int offset = 0,
  }) async {
    final datos = await _api.get(
      '/notas',
      query: {...filtros.aQuery(), 'limit': limit, 'offset': offset},
    );
    return convertirRespuesta(datos, (d) => _lista(d, Nota.fromJson));
  }

  Future<Nota> obtener(int id) async => _nota(await _api.get('/notas/$id'));

  Future<Nota> crear(NotaEntrada entrada) async =>
      _nota(await _api.post('/notas', datos: entrada.aJsonCrear()));

  Future<Nota> actualizar(int id, Map<String, dynamic> cambios) async =>
      _nota(await _api.patch('/notas/$id', datos: cambios));

  Future<void> eliminar(int id) => _api.delete('/notas/$id');

  Future<List<NotaPublica>> publicas({
    String? clasificador,
    String? q,
    int limit = 20,
    int offset = 0,
  }) async {
    final datos = await _api.get(
      '/notas/publicas',
      query: {
        'clasificador': clasificador,
        'q': q,
        'limit': limit,
        'offset': offset,
      },
    );
    return convertirRespuesta(datos, (d) => _lista(d, NotaPublica.fromJson));
  }

  /// Copia local de la primera página sin filtros, para verla sin conexión.
  /// Una copia dañada se ignora.
  List<Nota>? notasGuardadas(int usuarioId) {
    try {
      return _cache.leerNotas(usuarioId)?.map(Nota.fromJson).toList();
    } on TypeError {
      return null;
    }
  }

  Future<void> guardarNotas(int usuarioId, List<Nota> notas) =>
      _cache.guardarNotas(usuarioId, notas.map((n) => n.toJson()).toList());

  static Nota _nota(Object? datos) => convertirRespuesta(
    datos,
    (d) => Nota.fromJson(d as Map<String, dynamic>),
  );

  static List<T> _lista<T>(
    Object? datos,
    T Function(Map<String, dynamic>) conversor,
  ) => (datos as List).cast<Map<String, dynamic>>().map(conversor).toList();
}
