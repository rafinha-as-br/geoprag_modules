import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/form_validators.dart';

/// Campo numérico inteiro — recusa caracteres não numéricos na digitação e
/// exige um valor presente e maior que zero, devolvendo o valor já
/// convertido para `int` em vez de uma `String` a ser parseada por quem
/// consome.
///
/// Não desenha [label] como `labelText` por padrão: quando este campo é
/// composto dentro de um `BaseFormField` (o uso mais comum no pacote), o
/// rótulo já é exibido por ele — repeti-lo aqui duplicaria visualmente o
/// texto. [label] alimenta só a semântica de acessibilidade; passe
/// [decoration] explicitamente para um `labelText` visível em uso fora de
/// `BaseFormField`.
///
/// Primeira entrega da biblioteca de inputs reutilizáveis (GEOPRAG-136),
/// para o caso que originou o épico: os parâmetros do Ponto de Aplicação
/// aceitavam letra e número zerado/negativo sem nenhum aviso em tela
/// (GEOPRAG-144).
class GeopragNumeroInteiroInput extends StatelessWidget {
  final String label;
  final int? initialValue;
  final ValueChanged<int?> onChanged;
  final bool obrigatorio;
  final InputDecoration? decoration;
  final String? mensagemObrigatorio;
  final String? mensagemInvalido;
  final bool enabled;

  const GeopragNumeroInteiroInput({
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
        initialValue: initialValue?.toString(),
        decoration: decoration ?? const InputDecoration(),
        enabled: enabled,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (texto) => onChanged(int.tryParse(texto)),
        validator: (texto) {
          if (texto == null || texto.isEmpty) {
            return obrigatorio
                ? (mensagemObrigatorio ?? 'Campo obrigatório.')
                : null;
          }
          return validarPositivo(
            int.tryParse(texto),
            mensagemInvalido: mensagemInvalido ?? 'Informe um valor maior que zero.',
          );
        },
      ),
    );
  }
}
