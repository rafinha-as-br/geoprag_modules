import '../../../src/entities/ponto_de_aplicacao.dart';
import 'ponto_de_aplicacao_view_model.dart';

/// Ação em lote aplicável a um conjunto de pontos selecionados na tela de
/// Bairro (GEOPRAG-101).
enum AcaoEmLote { ativar, desativar, atribuirAplicador }

extension AcaoEmLoteApresentacao on AcaoEmLote {
  String get rotulo => switch (this) {
    AcaoEmLote.ativar => 'ativar',
    AcaoEmLote.desativar => 'desativar',
    AcaoEmLote.atribuirAplicador => 'atribuir aplicador',
  };

  /// Particípio usado nas mensagens de resultado do lote (ex.: "3 ponto(s)
  /// ativado(s) com sucesso").
  String get participio => switch (this) {
    AcaoEmLote.ativar => 'ativado(s)',
    AcaoEmLote.desativar => 'desativado(s)',
    AcaoEmLote.atribuirAplicador => 'atribuído(s) ao aplicador escolhido',
  };

  /// Estados de origem a partir dos quais esta ação é permitida — mesma
  /// tabela descrita na issue GEOPRAG-101.
  Set<EstadoPontoDeAplicacao> get estadosDeOrigemValidos => switch (this) {
    AcaoEmLote.ativar => const {
      EstadoPontoDeAplicacao.direcionada,
      EstadoPontoDeAplicacao.inativa,
    },
    AcaoEmLote.desativar => const {
      EstadoPontoDeAplicacao.enderecada,
      EstadoPontoDeAplicacao.direcionada,
      EstadoPontoDeAplicacao.ativa,
      EstadoPontoDeAplicacao.inativa,
    },
    AcaoEmLote.atribuirAplicador => const {EstadoPontoDeAplicacao.enderecada},
  };
}

/// Um ponto selecionado que não pode receber a ação em lote no estado atual,
/// com o motivo pronto para exibição (`BatchReconcileDialog`).
class ItemIgnoradoDoLote {
  final PontoDeAplicacaoResumoViewModel item;
  final String motivo;

  const ItemIgnoradoDoLote({required this.item, required this.motivo});
}

/// Resultado de conferir a seleção atual contra os estados de origem válidos
/// de [AcaoEmLote] — nunca um booleano (decisão da issue GEOPRAG-101):
/// alguns pontos podem seguir para a ação, outros ficam de fora com motivo.
class ReconciliacaoDoLote {
  final List<PontoDeAplicacaoResumoViewModel> elegiveis;
  final List<ItemIgnoradoDoLote> ignorados;

  const ReconciliacaoDoLote({required this.elegiveis, required this.ignorados});

  bool get temElegiveis => elegiveis.isNotEmpty;
}

/// Particiona [selecionados] em elegíveis/ignorados para [acao], segundo
/// [AcaoEmLoteApresentacao.estadosDeOrigemValidos].
ReconciliacaoDoLote reconciliarLote({
  required AcaoEmLote acao,
  required List<PontoDeAplicacaoResumoViewModel> selecionados,
}) {
  final estadosValidos = acao.estadosDeOrigemValidos;
  final elegiveis = <PontoDeAplicacaoResumoViewModel>[];
  final ignorados = <ItemIgnoradoDoLote>[];
  for (final item in selecionados) {
    if (estadosValidos.contains(item.estado)) {
      elegiveis.add(item);
    } else {
      ignorados.add(
        ItemIgnoradoDoLote(
          item: item,
          motivo:
              'Estado atual (${item.estado.rotulo}) não permite '
              '${acao.rotulo}.',
        ),
      );
    }
  }
  return ReconciliacaoDoLote(elegiveis: elegiveis, ignorados: ignorados);
}
