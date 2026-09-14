import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/form_validators.dart';

/// Campo numérico decimal — aceita `,` ou `.` como separador decimal (o
/// teclado numérico de muitos dispositivos produz `.`, e recusar esse
/// caractere descartaria a tecla em silêncio), recusa qualquer outro
/// caractere não numérico na digitação, e exige um valor presente e maior
/// que zero. Devolve o valor já convertido para `double`, eliminando o
/// parse manual (`double.parse(...replaceAll(',', '.'))`) espalhado pelos
/// formulários que usam vazão, dosagem ou área.
///
/// Não desenha [label] como `labelText` por padrão — mesmo motivo do
/// campo numérico inteiro: evita duplicar visualmente o rótulo quando
/// composto dentro de um `BaseFormField`.
///
/// Segunda entrega da biblioteca de inputs reutilizáveis (GEOPRAG-136),
/// companheira do campo numérico inteiro (GEOPRAG-144).
class GeopragNumeroDecimalInput extends StatelessWidget {
  final String label;
  final double? initialValue;
  final ValueChanged<double?> onChanged;
  final bool obrigatorio;
  final InputDecoration? decoration;
  final String? mensagemObrigatorio;
  final String? mensagemInvalido;
  final bool enabled;

  const GeopragNumeroDecimalInput({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.obrigatorio = true,
    this.decoration,
    this.mensagemObrigatorio,
    this.mensagemInvalido,
    this.enabled = true,
  }) : assert(
         initialValue == null || initialValue > 0,
         'initialValue deve ser nulo ou maior que zero.',
       );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      textField: true,
      child: TextFormField(
        initialValue: initialValue == null
            ? null
            : formatarNumeroExibicao(initialValue!).replaceAll('.', ','),
        decoration: decoration ?? const InputDecoration(),
        enabled: enabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [_DecimalInputFormatter()],
        onChanged: (texto) => onChanged(decimalDoFormulario(texto)),
        validator: (texto) {
          if (texto == null || texto.isEmpty) {
            return obrigatorio
                ? (mensagemObrigatorio ?? 'Campo obrigatório.')
                : null;
          }
          return validarPositivo(
            decimalDoFormulario(texto),
            mensagemInvalido: mensagemInvalido ?? 'Informe um valor maior que zero.',
          );
        },
      ),
    );
  }
}

/// Aceita dígitos e, no máximo, um separador decimal (`,` ou `.`) — rejeita
/// qualquer outro caractere e a mistura dos dois separadores na mesma
/// edição. [decimalDoFormulario] já lê ambos os separadores corretamente.
class _DecimalInputFormatter extends TextInputFormatter {
  static final _padrao = RegExp(r'^\d*[.,]?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _padrao.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
