import 'package:mocktail/mocktail.dart';
import 'package:takenote/data/api_exception.dart';
import 'package:takenote/data/token_storage.dart';
import 'package:takenote/models/filtros_notas.dart';
import 'package:takenote/models/nota.dart';
import 'package:takenote/models/nota_entrada.dart';
import 'package:takenote/repositories/auth_repository.dart';
import 'package:takenote/repositories/ia_repository.dart';
import 'package:takenote/repositories/notas_repository.dart';

class MockNotasRepository extends Mock implements NotasRepository {}

class MockIaRepository extends Mock implements IaRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

void registrarFallbacks() {
  registerFallbackValue(const FiltrosNotas());
  registerFallbackValue(const NotaEntrada(titulo: 'x'));
}

/// `NotaOut` tal como lo devuelve el servidor.
Map<String, dynamic> notaJson({
  int id = 1,
  String titulo = 'Comprar pan',
  String? clasificador = 'compras',
  String? descripcion,
  Object? valor,
  bool revisada = false,
  bool prioritaria = false,
  bool publica = false,
}) => {
  'id': id,
  'usuario_id': 7,
  'clasificador': clasificador,
  'titulo': titulo,
  'descripcion': descripcion,
  'fecha_nota': '2026-10-20',
  'valor': valor,
  'revisada': revisada,
  'prioritaria': prioritaria,
  'publica': publica,
  'fecha_registro': '2026-10-20T14:30:00',
};

Nota nota({int id = 1, String titulo = 'Comprar pan', bool revisada = false}) =>
    Nota.fromJson(notaJson(id: id, titulo: titulo, revisada: revisada));

const errorSinConexion = ApiException(TipoError.sinConexion);
