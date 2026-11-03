import 'package:flutter/material.dart';

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

/// Campo de data de nascimento — abre [showDatePicker] ao tocar e formata o
/// valor selecionado como `dd/MM/yyyy`. Extraído de
/// `CriacaoDeAdministradorScreen` para reuso pelo formulário de cadastro do
/// Aplicador (GEOPRAG-65, que expõe o mesmo campo) e por qualquer outro
/// formulário de cadastro de usuário (feedback de revisão do PR #9).
class GeopragDataNascimentoInput extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final InputDecoration decoration;
  final FormFieldValidator<DateTime>? validator;
  final DateTime firstDate;
  final DateTime lastDate;

  GeopragDataNascimentoInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.decoration = const InputDecoration(labelText: 'Data de nascimento'),
    this.validator,
    DateTime? firstDate,
    DateTime? lastDate,
  }) : firstDate = firstDate ?? DateTime(1900),
       lastDate = lastDate ?? DateTime.now();

  // O padrão de "-18 anos" foi pensado para data de nascimento. Callers que
  // sobrescrevem firstDate/lastDate para outros propósitos (ex.: data de
  // entrega, validade) podem receber um padrão anterior a firstDate, o que
  // derruba a asserção interna do showDatePicker — por isso o clamp abaixo.
  DateTime get _initialDate {
    final desejada = value ?? DateTime(DateTime.now().year - 18);
    if (desejada.isBefore(firstDate)) return firstDate;
    if (desejada.isAfter(lastDate)) return lastDate;
    return desejada;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      builder: (field) => InkWell(
        onTap: () async {
          final selecionada = await showDatePicker(
            context: context,
            initialDate: _initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
          );
          if (selecionada != null) {
            onChanged(selecionada);
            field.didChange(selecionada);
          }
        },
        child: InputDecorator(
          decoration: decoration.copyWith(errorText: field.errorText),
          child: Text(value == null ? 'Selecione a data' : _formatarData(value!)),
        ),
      ),
    );
  }
}
