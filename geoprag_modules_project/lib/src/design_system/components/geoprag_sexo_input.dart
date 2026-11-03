import 'package:flutter/material.dart';

/// Opções básicas exibidas pelo [GeopragSexoInput] (feedback de revisão do
/// PR #12, GEOPRAG-65: campo passou de texto livre para dropdown).
const List<String> opcoesSexoGeoprag = ['Masculino', 'Feminino', 'Outro'];

/// Campo de seleção para "Sexo" — extraído de `CriacaoDeAdministradorScreen`
/// para reuso pelo formulário de cadastro do Aplicador (GEOPRAG-65, que
/// expõe o mesmo campo) e por qualquer outro formulário de cadastro de
/// usuário (feedback de revisão do PR #9).
class GeopragSexoInput extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final InputDecoration decoration;
  final bool enabled;
  final FormFieldValidator<String>? validator;

  const GeopragSexoInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.decoration = const InputDecoration(labelText: 'Sexo'),
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: decoration,
      items: [
        for (final opcao in opcoesSexoGeoprag)
          DropdownMenuItem(value: opcao, child: Text(opcao)),
      ],
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }
}
