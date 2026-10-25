/// Nombres de rutas de la app.
abstract final class Rutas {
  static const splash = '/';
  static const login = '/login';
  static const registro = '/registro';
  static const notas = '/notas';

  /// Argumento: la [Nota] a mostrar.
  static const detalle = '/nota';

  /// Argumento: la [Nota] a editar, o nada para crear.
  static const formulario = '/nota/formulario';
  static const publicas = '/publicas';
  static const resumen = '/resumen';
}
