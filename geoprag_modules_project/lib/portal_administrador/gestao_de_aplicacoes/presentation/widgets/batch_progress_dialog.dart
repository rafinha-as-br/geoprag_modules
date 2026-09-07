import 'package:flutter/material.dart';

import '../../../../src/errors/app_exceptions.dart';
import '../../../../src/errors/app_logger.dart';

/// Resultado final de um [BatchProgressDialog]: quais ids foram concluídos
/// com sucesso e quais falharam (com o motivo), depois de todas as
/// tentativas que o usuário decidiu fazer.
class BatchProgressResultado {
  final List<String> sucesso;
  final Map<String, String> falhas;

  const BatchProgressResultado({required this.sucesso, required this.falhas});

  bool get sucessoTotal => falhas.isEmpty;
  bool get falhaTotal => sucesso.isEmpty && falhas.isNotEmpty;
}

/// Executa [executarUm] para cada id de [ids], sequencialmente, mostrando
/// progresso "N de M" ao vivo. Ao final: sucesso total fecha só com
/// "Concluir"; havendo falha (parcial ou total), oferece "Tentar novamente"
/// — que reprocessa apenas os ids que falharam, preservando os já
/// concluídos (GEOPRAG-101: "sucesso total / parcial com retry do que
/// falhou / falha total").
///
/// Bloqueante enquanto executa: não fecha por toque fora nem pelo botão de
/// voltar, para não deixar a ação em lote pela metade sem o usuário saber.
class BatchProgressDialog extends StatefulWidget {
  const BatchProgressDialog({
    super.key,
    required this.ids,
    required this.executarUm,
  });

  final List<String> ids;
  final Future<void> Function(String id) executarUm;

  @override
  State<BatchProgressDialog> createState() => _BatchProgressDialogState();
}

class _BatchProgressDialogState extends State<BatchProgressDialog> {
  // ignore: prefer_final_fields
  late List<String> _pendentes = List.of(widget.ids);
  final List<String> _sucesso = [];
  final Map<String, String> _falhas = {};
  bool _executando = true;

  @override
  void initState() {
    super.initState();
    _executar();
  }

  Future<void> _executar() async {
    setState(() => _executando = true);
    final tentativa = List<String>.from(_pendentes);
    for (final id in tentativa) {
      try {
        await widget.executarUm(id);
        _sucesso.add(id);
        _pendentes.remove(id);
        _falhas.remove(id);
      } catch (e, stackTrace) {
        _falhas[id] = _mensagemDeErro(id, e, stackTrace);
      }
      if (mounted) setState(() {});
    }
    if (mounted) setState(() => _executando = false);
  }

  /// Erros de domínio (`EntidadeNaoEncontradaException`/
  /// `OperacaoNaoPermitidaException`) já trazem uma mensagem pronta para a
  /// UI. Qualquer outra exceção é inesperada — registrada via [AppLogger]
  /// (nunca engolida silenciosamente) antes de mostrar uma mensagem genérica.
  String _mensagemDeErro(String id, Object e, StackTrace stackTrace) {
    return switch (e) {
      EntidadeNaoEncontradaException(:final mensagemAmigavel) => mensagemAmigavel,
      OperacaoNaoPermitidaException(:final mensagemAmigavel) => mensagemAmigavel,
      _ => () {
        AppLogger.error('BatchProgressDialog._executar (id=$id)', e, stackTrace);
        return 'Falha inesperada.';
      }(),
    };
  }

  void _concluir() {
    Navigator.of(
      context,
    ).pop(BatchProgressResultado(sucesso: _sucesso, falhas: Map.of(_falhas)));
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.ids.length;
    final concluidos = _sucesso.length + _falhas.length;
    return PopScope(
      canPop: !_executando,
      child: AlertDialog(
        title: const Text('Processando lote'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(value: total == 0 ? 0 : concluidos / total),
              const SizedBox(height: 12),
              Text('$concluidos de $total processados.'),
              if (!_executando) ...[
                const SizedBox(height: 16),
                if (_falhas.isEmpty)
                  const Text(
                    'Concluído com sucesso.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                else ...[
                  Text(
                    _sucesso.isEmpty
                        ? 'Falha em todos os itens:'
                        : '${_sucesso.length} concluído(s); '
                              '${_falhas.length} falharam:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._falhas.entries.map(
                    (entrada) => Text(
                      '• ${entrada.key} — ${entrada.value}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        actions: _executando
            ? const []
            : [
                if (_falhas.isNotEmpty)
                  TextButton(
                    onPressed: _executar,
                    child: const Text('Tentar novamente'),
                  ),
                FilledButton(
                  onPressed: _concluir,
                  child: Text(_falhas.isEmpty ? 'Concluir' : 'Concluir mesmo assim'),
                ),
              ],
      ),
    );
  }
}
