import 'package:flutter/material.dart';

final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Campo de e-mail com validação de formato embutida — extraído de
/// `CriacaoDeAdministradorScreen`, que validava apenas a presença do valor,
/// sem checar o formato do e-mail (feedback de revisão do PR #9).
///
/// Valida obrigatoriedade e formato por padrão; [validator] permite
/// validação adicional (ex.: mensagem de e-mail duplicado vinda do
/// back-end), aplicada depois da validação embutida.
class GeopragEmailInput extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const GeopragEmailInput({
    super.key,
    required this.controller,
    this.decoration = const InputDecoration(),
    this.enabled = true,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      decoration: decoration,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe o e-mail institucional.';
        }
        if (!_emailRegex.hasMatch(value)) {
          return 'Informe um e-mail válido.';
        }
        return validator?.call(value);
      },
    );
  }
}
