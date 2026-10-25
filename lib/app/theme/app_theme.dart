import 'package:flutter/material.dart';

/// Tema único de la app (Material 3). Las pantallas usan `Theme.of(context)`
/// y no definen colores propios.
abstract final class AppTheme {
  static const _semilla = Color(0xFF2E7D6B);

  static final ThemeData claro = _crear(Brightness.light);
  static final ThemeData oscuro = _crear(Brightness.dark);

  static ThemeData _crear(Brightness brillo) {
    final esquema = ColorScheme.fromSeed(
      seedColor: _semilla,
      brightness: brillo,
    );
    final redondeado = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: esquema.surface,
        foregroundColor: esquema.onSurface,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: esquema.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: esquema.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquema.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: redondeado,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: redondeado,
        ),
      ),
      chipTheme: ChipThemeData(shape: redondeado),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: esquema.primaryContainer,
        foregroundColor: esquema.onPrimaryContainer,
      ),
    );
  }
}
