import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/nota_form_controller.dart';
import '../../widgets/avisos.dart';
import '../../widgets/campo_fecha.dart';
import '../../widgets/error_formulario.dart';

/// El State solo guarda la clave del formulario; los datos viven en
/// [NotaFormController].
class NotaFormScreen extends StatefulWidget {
  const NotaFormScreen({super.key});

  @override
  State<NotaFormScreen> createState() => _NotaFormScreenState();
}

class _NotaFormScreenState extends State<NotaFormScreen> {
  final _c = Get.find<NotaFormController>();
  final _form = GlobalKey<FormState>();

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    final nota = await _c.guardar();
    if (nota == null) return;
    Get.back();
    mostrarAviso(_c.editando ? 'Nota actualizada' : 'Nota creada');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_c.editando ? 'Editar nota' : 'Nueva nota'),
      actions: [
        Obx(
          () => TextButton(
            onPressed: _c.guardando.value ? null : _guardar,
            child: const Text('Guardar'),
          ),
        ),
      ],
    ),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Obx(
            () => _c.mensajeError.value == null
                ? const SizedBox.shrink()
                : ErrorFormulario(mensaje: _c.mensajeError.value!),
          ),
          Obx(
            () => TextFormField(
              controller: _c.titulo,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: NotaFormController.validarTitulo,
              forceErrorText: _c.erroresCampo['titulo'],
              onChanged: (_) => _c.erroresCampo.remove('titulo'),
              decoration: const InputDecoration(labelText: 'Título *'),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => TextFormField(
              controller: _c.clasificador,
              textInputAction: TextInputAction.next,
              validator: NotaFormController.validarClasificador,
              forceErrorText: _c.erroresCampo['clasificador'],
              onChanged: (_) => _c.erroresCampo.remove('clasificador'),
              decoration: const InputDecoration(
                labelText: 'Clasificador',
                helperText: 'Una sola palabra, p. ej. trabajo o compras',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => TextFormField(
              controller: _c.descripcion,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              forceErrorText: _c.erroresCampo['descripcion'],
              onChanged: (_) => _c.erroresCampo.remove('descripcion'),
              decoration: const InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(
                  () => CampoFecha(
                    etiqueta: 'Fecha de la nota',
                    valor: _c.fechaNota.value,
                    alCambiar: (f) => _c.fechaNota.value = f,
                    textoVacio: 'Hoy',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => TextFormField(
                    controller: _c.valor,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: NotaFormController.validarValor,
                    forceErrorText: _c.erroresCampo['valor'],
                    onChanged: (_) => _c.erroresCampo.remove('valor'),
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Obx(
              () => Column(
                children: [
                  SwitchListTile(
                    title: const Text('Revisada'),
                    value: _c.revisada.value,
                    onChanged: (v) => _c.revisada.value = v,
                  ),
                  SwitchListTile(
                    title: const Text('Prioritaria'),
                    value: _c.prioritaria.value,
                    onChanged: (v) => _c.prioritaria.value = v,
                  ),
                  SwitchListTile(
                    title: const Text('Pública'),
                    subtitle: const Text('Visible para otros usuarios'),
                    value: _c.publica.value,
                    onChanged: (v) => _c.publica.value = v,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => FilledButton.icon(
              onPressed: _c.guardando.value ? null : _guardar,
              icon: _c.guardando.value
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_c.editando ? 'Guardar cambios' : 'Crear nota'),
            ),
          ),
        ],
      ),
    ),
  );
}
