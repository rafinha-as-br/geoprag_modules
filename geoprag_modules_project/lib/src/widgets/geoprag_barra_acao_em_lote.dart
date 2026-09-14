import 'package:flutter/material.dart';

/// Um botão de ação da [GeopragBarraAcaoEmLote].
class GeopragAcaoEmLoteBotao {
  const GeopragAcaoEmLoteBotao({
    this.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Key? key;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
}

/// Barra de ações em lote reutilizável: "N selecionado(s)" + [acoes] +
/// "Limpar seleção". Fundo `primaryContainer` com todo o conteúdo (texto,
/// ícone, borda) em `onPrimaryContainer` — o par de contraste correto
/// (GEOPRAG-67, PR #14): aplicar a cor só no `Text` ambiente não basta,
/// `OutlinedButton`/`TextButton` não herdam `ColorScheme.onPrimaryContainer`
/// sozinhos, e ficam ilegíveis sobre o fundo escuro.
///
/// Fica sempre presente no layout (altura reservada) e só alterna
/// visibilidade via opacidade — nunca entra/sai da árvore condicionalmente
/// — para manter a posição de tela estável entre um clique e o próximo
/// (GEOPRAG-67/130).
class GeopragBarraAcaoEmLote extends StatelessWidget {
  const GeopragBarraAcaoEmLote({
    super.key,
    this.opacityKey,
    this.ignorePointerKey,
    this.limparSelecaoKey,
    required this.quantidade,
    required this.processando,
    required this.acoes,
    required this.onLimparSelecao,
  });

  final Key? opacityKey;
  final Key? ignorePointerKey;
  final Key? limparSelecaoKey;
  final int quantidade;
  final bool processando;
  final List<GeopragAcaoEmLoteBotao> acoes;
  final VoidCallback? onLimparSelecao;

  @override
  Widget build(BuildContext context) {
    final onPrimaryContainer = Theme.of(context).colorScheme.onPrimaryContainer;

    return IgnorePointer(
      key: ignorePointerKey,
      ignoring: quantidade == 0,
      child: Opacity(
        key: opacityKey,
        opacity: quantidade == 0 ? 0 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                '$quantidade selecionado(s)',
                style: TextStyle(color: onPrimaryContainer),
              ),
              for (final acao in acoes)
                OutlinedButton.icon(
                  key: acao.key,
                  onPressed: acao.onPressed,
                  icon: Icon(acao.icon, color: onPrimaryContainer),
                  label: Text(
                    acao.label,
                    style: TextStyle(color: onPrimaryContainer),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: onPrimaryContainer),
                  ),
                ),
              TextButton(
                key: limparSelecaoKey,
                onPressed: processando ? null : onLimparSelecao,
                child: Text(
                  'Limpar seleção',
                  style: TextStyle(color: onPrimaryContainer),
                ),
              ),
              if (processando)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: onPrimaryContainer,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
