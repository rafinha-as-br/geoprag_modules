import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de CPF com máscara `000.000.000-00` aplicada durante a digitação —
/// extraído de `VerificarCodigoAdminScreen` e `CriacaoDeAdministradorScreen`,
/// que duplicavam o mesmo formatter (feedback de revisão do PR #9).
///
/// Não impõe decoração fixa: o chamador controla `decoration` para manter o
/// visual de cada tela (ex.: com ou sem rótulo, ícone, borda arredondada).
class GeopragCpfInput extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const GeopragCpfInput({
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
        _CpfInputFormatter(),
      ],
      decoration: decoration,
      onChanged: onChanged,
      validator: validator,
    );
  }
}

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.substring(
      0,
      newValue.text.length.clamp(0, 11),
    );
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('-');
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
