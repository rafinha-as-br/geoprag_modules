import 'package:flutter/material.dart';

import '../../../../src/entities/ponto_de_aplicacao.dart';

/// Campos do agendamento do ciclo — data da 1ª aplicação, intervalo em dias
/// (padrão 15) e quantidade de recorrências — compartilhados entre o
/// agendamento em lote (GEOPRAG-101, `BatchReconcileDialog`) e o agendamento
/// individual (GEOPRAG-110, `AtivacaoDialog`). Não valida "data no passado"
/// via mensagem de campo — o `firstDate` do `showDatePicker` já impede a
/// escolha.
///
/// Não intervalo máximo: a RN de Dosagem menciona 20 dias como limite
/// biológico do BTI, mas é referência técnica, não regra de software
/// (decisão registrada na GEOPRAG-110).
///
/// Notifica [onChanged] com o [Agendamento] gerado sempre que o formulário
/// está válido, ou `null` enquanto não estiver — o diálogo pai decide o que
/// fazer com isso (normalmente, habilitar/desabilitar o botão de confirmar).
class FormularioDeAgendamento extends StatefulWidget {
  const FormularioDeAgendamento({super.key, required this.onChanged});

  final ValueChanged<Agendamento?> onChanged;

  @override
  State<FormularioDeAgendamento> createState() =>
      _FormularioDeAgendamentoState();
}

class _FormularioDeAgendamentoState extends State<FormularioDeAgendamento> {
  DateTime? _dataInicio;
  final _intervaloController = TextEditingController(text: '15');
  final _recorrenciasController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    // Adiado para depois do primeiro frame: `onChanged` normalmente muda o
    // estado de um diálogo ancestral (`setState`), e chamar isso direto no
    // `initState` acontece *durante* o build desse ancestral — Flutter
    // rejeita com "setState() or markNeedsBuild() called during build."
    // (reproduzido ao extrair este formulário do BatchReconcileDialog).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _notificar();
    });
  }

  @override
  void dispose() {
    _intervaloController.dispose();
    _recorrenciasController.dispose();
    super.dispose();
  }

  void _notificar() {
    final dataInicio = _dataInicio;
    final intervalo = int.tryParse(_intervaloController.text);
    final recorrencias = int.tryParse(_recorrenciasController.text);
    final valido =
        dataInicio != null &&
        intervalo != null &&
        intervalo > 0 &&
        recorrencias != null &&
        recorrencias > 0;
    widget.onChanged(
      valido
          ? Agendamento.gerar(
              dataInicio: dataInicio,
              intervaloDias: intervalo,
              quantidadeRecorrencias: recorrencias,
            )
          : null,
    );
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataInicio ?? hoje,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 365)),
    );
    if (escolhida != null) {
      setState(() => _dataInicio = escolhida);
      _notificar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: _escolherData,
          icon: const Icon(Icons.calendar_today, size: 18),
          label: Text(
            _dataInicio == null
                ? 'Escolher data da 1ª aplicação'
                : 'Início: ${_dataInicio!.day.toString().padLeft(2, '0')}/'
                      '${_dataInicio!.month.toString().padLeft(2, '0')}/'
                      '${_dataInicio!.year}',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _intervaloController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Intervalo (dias)'),
          onChanged: (_) => _notificar(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _recorrenciasController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantidade de recorrências',
          ),
          onChanged: (_) => _notificar(),
        ),
      ],
    );
  }
}
