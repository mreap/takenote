import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/error_formulario.dart';
import 'auth_widgets.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _auth = Get.find<AuthController>();
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  final _confirmacion = TextEditingController();

  @override
  void initState() {
    super.initState();
    _auth.limpiarError();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _clave.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    if (await _auth.registrar(_nombre.text, _correo.text, _clave.text)) {
      Get.offAllNamed(Rutas.notas);
    }
  }

  void _volverALogin() {
    _auth.limpiarError();
    Get.back();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(onPressed: _volverALogin),
      title: const Text('Crear cuenta'),
    ),
    body: Form(
      key: _form,
      child: MarcoAuth(
        subtitulo: 'Regístrate para guardar tus notas',
        hijos: [
          Obx(
            () => _auth.mensajeError.value == null
                ? const SizedBox.shrink()
                : ErrorFormulario(mensaje: _auth.mensajeError.value!),
          ),
          Obx(
            () => TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: ValidarAuth.nombre,
              forceErrorText: _auth.erroresCampo['nombre'],
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => TextFormField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
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
              etiqueta: 'Clave (mínimo 6 caracteres)',
              validator: ValidarAuth.claveNueva,
              errorServidor: _auth.erroresCampo['clave'],
              accion: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 16),
          CampoClave(
            controller: _confirmacion,
            etiqueta: 'Confirmar clave',
            validator: (v) =>
                v == _clave.text ? null : 'Las claves no coinciden.',
            alEnviar: _registrar,
          ),
          const SizedBox(height: 24),
          Obx(
            () => FilledButton(
              onPressed: _auth.cargando.value ? null : _registrar,
              child: _auth.cargando.value
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear cuenta'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _volverALogin,
            child: const Text('¿Ya tienes cuenta? Inicia sesión'),
          ),
        ],
      ),
    ),
  );
}
