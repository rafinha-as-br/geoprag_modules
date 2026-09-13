import 'package:flutter/material.dart';

import '../utils/form_validators.dart';

/// Campo de texto livre com obrigatoriedade e limite de tamanho
/// configuráveis.
///
/// Não desenha [label] como `labelText` por padrão — mesmo motivo dos
/// campos numéricos: evita duplicar visualmente o rótulo quando composto
/// dentro de um `BaseFormField`, que já exibe esse texto.
///
/// Terceira entrega da biblioteca de inputs reutilizáveis (GEOPRAG-136),
/// companheira dos campos numéricos inteiro e decimal (GEOPRAG-144).
class GeopragTextoInput extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final bool obrigatorio;
  final int? tamanhoMaximo;
  final int maxLinhas;
  final InputDecoration? decoration;

  const GeopragTextoInput({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.obrigatorio = true,
    this.tamanhoMaximo,
    this.maxLinhas = 1,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      textField: true,
      child: TextFormField(
        initialValue: initialValue,
        decoration: decoration ?? const InputDecoration(),
        maxLength: tamanhoMaximo,
        maxLines: maxLinhas,
        onChanged: onChanged,
        validator: obrigatorio
            ? (texto) => validarObrigatorio(texto, 'Campo obrigatório.')
            : null,
      ),
    );
  }
}
