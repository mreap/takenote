import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/bindings/dependencias.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'widgets/avisos.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await registrarDependencias();
  runApp(const TakeNoteApp());
}

class TakeNoteApp extends StatelessWidget {
  const TakeNoteApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    title: 'TakeNote',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.claro,
    darkTheme: AppTheme.oscuro,
    scaffoldMessengerKey: avisosKey,
    locale: const Locale('es'),
    supportedLocales: const [Locale('es'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    initialRoute: Rutas.splash,
    getPages: AppPages.paginas,
  );
}
