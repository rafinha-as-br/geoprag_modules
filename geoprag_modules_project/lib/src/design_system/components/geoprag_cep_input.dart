import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de CEP com máscara `00000-000` aplicada durante a digitação —
/// mesmo padrão de [GeopragCpfInput], extraído do formulário de cadastro do
/// Aplicador (feedback de revisão do PR #12, GEOPRAG-65).
///
/// Não impõe decoração fixa: o chamador controla `decoration` para manter o
/// visual de cada tela.
class GeopragCepInput extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const GeopragCepInput({
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
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CepInputFormatter(),
      ],
      decoration: decoration,
      onChanged: onChanged,
      validator:
          validator ??
          (value) {
            if (value == null || value.length != 9) {
              return 'Informe um CEP válido.';
            }
            return null;
          },
    );
  }
}

class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.substring(
      0,
      newValue.text.length.clamp(0, 8),
    );
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 4) buffer.write('-');
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
