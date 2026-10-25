import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/error_formulario.dart';
import 'auth_widgets.dart';

/// El State solo guarda la clave del formulario y los campos de texto; el
/// estado de la sesión vive en [AuthController].
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = Get.find<AuthController>();
  final _form = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _clave = TextEditingController();

  @override
  void initState() {
    super.initState();
    _auth.limpiarError();
  }

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    if (await _auth.login(_correo.text, _clave.text)) {
      Get.offAllNamed(Rutas.notas);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Form(
      key: _form,
      child: MarcoAuth(
        subtitulo: 'Inicia sesión para ver tus notas',
        hijos: [
          Obx(
            () => _auth.mensajeError.value == null
                ? const SizedBox.shrink()
                : ErrorFormulario(mensaje: _auth.mensajeError.value!),
          ),
          Obx(
            () => TextFormField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              validator: ValidarAuth.correo,
              forceErrorText: _auth.erroresCampo['correo'],
              decoration: const InputDecoration(
                labelText: 'Correo',
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => CampoClave(
              controller: _clave,
              etiqueta: 'Clave',
              validator: ValidarAuth.claveLogin,
              errorServidor: _auth.erroresCampo['clave'],
              alEnviar: _entrar,
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => FilledButton(
              onPressed: _auth.cargando.value ? null : _entrar,
              child: _auth.cargando.value
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Iniciar sesión'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Get.toNamed(Rutas.registro),
            child: const Text('¿No tienes cuenta? Regístrate'),
          ),
        ],
      ),
    ),
  );
}
