import 'package:flutter/material.dart';

/// Campo de e-mail com teclado apropriado — extraído das telas de cadastro
/// de Administrador e Aplicador, que duplicavam o mesmo `TextFormField`
/// (feedback de revisão do PR #12, GEOPRAG-65).
///
/// Não impõe decoração nem validação fixas: o chamador controla `decoration`
/// e `validator` para manter o rótulo e a mensagem de cada tela.
class GeopragEmailInput extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final bool enabled;
  final FormFieldValidator<String>? validator;

  const GeopragEmailInput({
    super.key,
    required this.controller,
    this.decoration = const InputDecoration(labelText: 'E-mail'),
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      decoration: decoration,
      validator: validator,
    );
  }
}
