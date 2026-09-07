import 'package:flutter/material.dart';

import '../../../../src/entities/ponto_de_aplicacao.dart';
import '../lote_de_pontos_reconciliacao.dart';

/// Uma opção de aplicador para o formulário de "Atribuir aplicador em
/// lote" — só o suficiente para popular um dropdown, sem acoplar este
/// diálogo ao ViewModel do módulo de Aplicadores.
class AplicadorOpcao {
  final String id;
  final String nome;

  const AplicadorOpcao({required this.id, required this.nome});
}

/// O que o usuário confirmou no [BatchReconcileDialog], pronto para a tela
/// disparar a execução ([BatchProgressDialog]) sobre
/// [ReconciliacaoDoLote.elegiveis].
class BatchReconcileConfirmado {
  /// Preenchido só quando a ação é [AcaoEmLote.ativar].
  final Agendamento? agendamento;

  /// Preenchido só quando a ação é [AcaoEmLote.atribuirAplicador].
  final String? aplicadorId;

  const BatchReconcileConfirmado({this.agendamento, this.aplicadorId});
}

/// Mostra os pontos elegíveis e ignorados (com motivo) para [acao], e — para
/// as ações que precisam de um dado extra do usuário (agendamento do lote
/// para Ativar; aplicador para Atribuir aplicador) — o formulário
/// correspondente. Confirmar aqui não executa a ação: devolve
/// [BatchReconcileConfirmado] via `Navigator.pop`, para a tela seguir com o
/// `BatchProgressDialog`.
class BatchReconcileDialog extends StatefulWidget {
  const BatchReconcileDialog({
    super.key,
    required this.acao,
    required this.reconciliacao,
    this.aplicadoresDisponiveis,
  });

  final AcaoEmLote acao;
  final ReconciliacaoDoLote reconciliacao;

  /// Obrigatório (não vazio) quando [acao] é [AcaoEmLote.atribuirAplicador].
  final List<AplicadorOpcao>? aplicadoresDisponiveis;

  @override
  State<BatchReconcileDialog> createState() => _BatchReconcileDialogState();
}

class _BatchReconcileDialogState extends State<BatchReconcileDialog> {
  DateTime? _dataInicio;
  final _intervaloController = TextEditingController(text: '15');
  final _recorrenciasController = TextEditingController(text: '1');
  String? _aplicadorSelecionadoId;

  @override
  void dispose() {
    _intervaloController.dispose();
    _recorrenciasController.dispose();
    super.dispose();
  }

  bool get _formularioValido {
    switch (widget.acao) {
      case AcaoEmLote.ativar:
        final intervalo = int.tryParse(_intervaloController.text);
        final recorrencias = int.tryParse(_recorrenciasController.text);
        return _dataInicio != null &&
            intervalo != null &&
            intervalo > 0 &&
            recorrencias != null &&
            recorrencias > 0;
      case AcaoEmLote.atribuirAplicador:
        return _aplicadorSelecionadoId != null;
      case AcaoEmLote.desativar:
        return true;
    }
  }

  void _confirmar() {
    switch (widget.acao) {
      case AcaoEmLote.ativar:
        Navigator.of(context).pop(
          BatchReconcileConfirmado(
            agendamento: Agendamento.gerar(
              dataInicio: _dataInicio!,
              intervaloDias: int.parse(_intervaloController.text),
              quantidadeRecorrencias: int.parse(_recorrenciasController.text),
            ),
          ),
        );
      case AcaoEmLote.atribuirAplicador:
        Navigator.of(
          context,
        ).pop(BatchReconcileConfirmado(aplicadorId: _aplicadorSelecionadoId));
      case AcaoEmLote.desativar:
        Navigator.of(context).pop(const BatchReconcileConfirmado());
    }
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataInicio ?? hoje,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 365)),
    );
    if (escolhida != null) setState(() => _dataInicio = escolhida);
  }

  @override
  Widget build(BuildContext context) {
    final reconciliacao = widget.reconciliacao;
    return AlertDialog(
      title: Text('Confirmar ${widget.acao.rotulo} em lote'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${reconciliacao.elegiveis.length} de '
                '${reconciliacao.elegiveis.length + reconciliacao.ignorados.length} '
                'selecionados serão ${widget.acao.participio}.',
              ),
              if (reconciliacao.elegiveis.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...reconciliacao.elegiveis.map(
                  (item) => Text('• ${item.nome}', style: const TextStyle(fontSize: 13)),
                ),
              ],
              if (reconciliacao.ignorados.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '${reconciliacao.ignorados.length} não serão afetados:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...reconciliacao.ignorados.map(
                  (ignorado) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${ignorado.item.nome} — ${ignorado.motivo}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                ),
              ],
              if (reconciliacao.temElegiveis) ...[
                const Divider(height: 32),
                ..._formularioDaAcao(),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (reconciliacao.temElegiveis)
          FilledButton(
            onPressed: _formularioValido ? _confirmar : null,
            child: const Text('Confirmar'),
          ),
      ],
    );
  }

  List<Widget> _formularioDaAcao() {
    switch (widget.acao) {
      case AcaoEmLote.ativar:
        return [
          Text(
            'Agendamento do lote — mesma data, intervalo e recorrências '
            'para todos os elegíveis:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
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
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _recorrenciasController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantidade de recorrências'),
            onChanged: (_) => setState(() {}),
          ),
        ];
      case AcaoEmLote.atribuirAplicador:
        final opcoes = widget.aplicadoresDisponiveis ?? const [];
        return [
          DropdownButtonFormField<String>(
            initialValue: _aplicadorSelecionadoId,
            decoration: const InputDecoration(labelText: 'Aplicador responsável'),
            items: [
              for (final opcao in opcoes)
                DropdownMenuItem(value: opcao.id, child: Text(opcao.nome)),
            ],
            onChanged: (id) => setState(() => _aplicadorSelecionadoId = id),
          ),
        ];
      case AcaoEmLote.desativar:
        return const [];
    }
  }
}
