import 'package:flutter_test/flutter_test.dart';
import 'package:takenote/models/filtros_notas.dart';
import 'package:takenote/models/ia.dart';
import 'package:takenote/models/nota.dart';
import 'package:takenote/models/nota_entrada.dart';

import '../helpers/fakes.dart';

void main() {
  group('Nota', () {
    test('lee NotaOut con opcionales nulos', () {
      final n = Nota.fromJson(notaJson(clasificador: null));
      expect(n.clasificador, isNull);
      expect(n.descripcion, isNull);
      expect(n.valor, isNull);
      expect(n.fechaNota, DateTime(2026, 10, 20));
    });

    test('valor entero del JSON se convierte a double', () {
      expect(Nota.fromJson(notaJson(valor: 15)).valor, 15.0);
    });

    test('toJson y fromJson son simétricos (copia local)', () {
      final n = Nota.fromJson(notaJson(valor: 2.5, descripcion: 'x'));
      final copia = Nota.fromJson(n.toJson());
      expect(copia.toJson(), n.toJson());
    });

    test('NotaPublica incluye el autor', () {
      final p = NotaPublica.fromJson({
        ...notaJson(publica: true),
        'autor': 'Ana',
      });
      expect(p.autor, 'Ana');
      expect(p.publica, isTrue);
    });
  });

  group('NotaEntrada', () {
    test('al crear omite los opcionales vacíos', () {
      const e = NotaEntrada(titulo: 'Hola');
      expect(e.aJsonCrear(), {
        'titulo': 'Hola',
        'revisada': false,
        'prioritaria': false,
        'publica': false,
      });
    });

    test('al crear envía la fecha como yyyy-MM-dd', () {
      final e = NotaEntrada(titulo: 'Hola', fechaNota: DateTime(2026, 3, 5));
      expect(e.aJsonCrear()['fecha_nota'], '2026-03-05');
    });

    test('al editar solo envía lo que cambió y null para borrar', () {
      final original = Nota.fromJson(
        notaJson(descripcion: 'vieja', valor: 3, clasificador: 'casa'),
      );
      final e = NotaEntrada(
        titulo: original.titulo,
        clasificador: 'casa',
        descripcion: null,
        fechaNota: original.fechaNota,
        valor: 3,
        prioritaria: true,
      );
      expect(e.aJsonActualizar(original), {
        'descripcion': null,
        'prioritaria': true,
      });
    });
  });

  test('FiltrosNotas genera la query del contrato', () {
    final f = FiltrosNotas(
      clasificador: 'trabajo',
      revisada: false,
      desde: DateTime(2026, 1, 1),
    ).conBusqueda('  reunión ');
    expect(f.aQuery(), {
      'clasificador': 'trabajo',
      'revisada': false,
      'prioritaria': null,
      'q': 'reunión',
      'desde': '2026-01-01',
      'hasta': null,
    });
    expect(f.cantidadActivos, 3);
  });

  test('ResumenNotas y SugerenciaNota se leen del contrato', () {
    final r = ResumenNotas.fromJson({
      'total_notas': 2,
      'resumen': 'Todo bien',
      'pendientes_clave': ['a'],
      'sugerencias': ['b', 'c'],
    });
    expect(r.sugerencias, ['b', 'c']);
    final s = SugerenciaNota.fromJson({
      'clasificador': 'trabajo',
      'prioritaria': true,
      'titulo_sugerido': 'Reunión',
      'justificacion': 'Porque sí',
    });
    expect(s.tituloSugerido, 'Reunión');
  });
}
