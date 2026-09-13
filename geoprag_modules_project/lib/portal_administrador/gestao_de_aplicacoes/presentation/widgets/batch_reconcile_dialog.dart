import 'package:flutter/material.dart';

import '../../../../src/entities/ponto_de_aplicacao.dart';
import '../lote_de_pontos_reconciliacao.dart';
import 'formulario_de_agendamento.dart';

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
  Agendamento? _agendamento;
  String? _aplicadorSelecionadoId;

  bool get _formularioValido {
    switch (widget.acao) {
      case AcaoEmLote.ativar:
        return _agendamento != null;
      case AcaoEmLote.atribuirAplicador:
        return _aplicadorSelecionadoId != null;
      case AcaoEmLote.desativar:
        return true;
    }
  }

  void _confirmar() {
    switch (widget.acao) {
      case AcaoEmLote.ativar:
        Navigator.of(
          context,
        ).pop(BatchReconcileConfirmado(agendamento: _agendamento));
      case AcaoEmLote.atribuirAplicador:
        Navigator.of(
          context,
        ).pop(BatchReconcileConfirmado(aplicadorId: _aplicadorSelecionadoId));
      case AcaoEmLote.desativar:
        Navigator.of(context).pop(const BatchReconcileConfirmado());
    }
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
          FormularioDeAgendamento(
            onChanged: (agendamento) =>
                setState(() => _agendamento = agendamento),
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
