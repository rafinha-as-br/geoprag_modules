import 'package:flutter/material.dart';

/// Campo de texto livre para "Sexo" — extraído de
/// `CriacaoDeAdministradorScreen` para reuso pelo formulário de cadastro do
/// Aplicador (GEOPRAG-65, que expõe o mesmo campo) e por qualquer outro
/// formulário de cadastro de usuário (feedback de revisão do PR #9).
///
/// Continua sendo texto livre, não um dropdown: não há opções fixas
/// definidas em nenhuma regra de negócio até o momento.
class GeopragSexoInput extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final bool enabled;
  final FormFieldValidator<String>? validator;

  const GeopragSexoInput({
    super.key,
    required this.controller,
    this.decoration = const InputDecoration(labelText: 'Sexo'),
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: decoration,
      validator: validator,
    );
  }
}
