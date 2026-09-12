import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/widgets/base_list_screen.dart';
import '../../../src/widgets/geoprag_search_field.dart';
import '../../autenticacao/core/admin_navigator.dart';
import '../../gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import '../core/admin_ponto_de_aplicacao_repository.dart';
import 'lote_de_pontos_reconciliacao.dart';
import 'ponto_de_aplicacao_view_model.dart';
import 'widgets/barra_acao_em_lote_pontos.dart';
import 'widgets/batch_reconcile_dialog.dart';
import 'widgets/ponto_de_aplicacao_colunas.dart';

/// Lista os Pontos de Aplicação de um bairro específico, aberta a partir da
/// legenda do mapa no dashboard.
///
/// Diferente do dashboard, aqui não há filtro de estado nem checkbox de
/// desativados: esta tela é o recorte de um bairro, e esconder parte dele
/// deixaria o administrador sem a visão completa do que existe ali.
///
/// GEOPRAG-101: também orquestra a seleção múltipla genérica
/// ([BaseListScreenController]) e as ações em lote sobre os pontos
/// selecionados — a abertura dos diálogos (que precisam de `BuildContext`)
/// fica a cargo de quem consome [reconciliar]/[listarAplicadoresDisponiveis]/
/// [executarUm]/[recarregarAposLote] (ver `_BarraAcaoEmLotePontos`); o Cubit
/// nunca recebe `BuildContext` diretamente.
class PontosDoBairroCubit
    extends BaseListScreenController<PontoDeAplicacaoResumoViewModel> {
  PontosDoBairroCubit(this._repository, this._aplicadorRepository, this._bairro)
    : super(_initialModel(_bairro)) {
    // Só é possível referenciar `this` depois do `super(...)` — por isso a
    // coluna de seleção e a barra de ações em lote são acopladas aqui, e
    // não dentro de `_initialModel` (método estático, sem instância ainda).
    emit(
      state.copyWith(
        columns: colunasDePontoDeAplicacao(
          exibirBairro: false,
          controllerDeSelecao: this,
        ),
        batchActionBar: BarraAcaoEmLotePontos(cubit: this),
      ),
    );
    _carregar();
  }

  final AdminPontoDeAplicacaoRepository _repository;
  final AplicadorRepository _aplicadorRepository;
  final String _bairro;

  List<PontoDeAplicacaoResumoViewModel> _todos = [];
  String _busca = '';

  static BaseListScreenModel<PontoDeAplicacaoResumoViewModel> _initialModel(
    String bairro,
  ) {
    return BaseListScreenModel<PontoDeAplicacaoResumoViewModel>(
      title: bairro,
      entityLabel: 'os pontos de aplicação do bairro',
      emptyState: const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Nenhum ponto de aplicação cadastrado neste bairro.'),
      ),
      columns: colunasDePontoDeAplicacao(exibirBairro: false),
      onRowTap: (context, ponto) =>
          AdminNavigatorScope.of(context).toAplicacaoDetalhes(ponto.id),
    );
  }

  @override
  String idDoItem(PontoDeAplicacaoResumoViewModel item) => item.id;

  Future<void> _carregar() async {
    emitLoading();
    try {
      final pontos = await _repository.listarPorBairro(_bairro);
      final nomesPorAplicadorId = {
        for (final aplicador in await _aplicadorRepository.listar())
          aplicador.id: aplicador.nome,
      };
      _todos = [
        for (final ponto in pontos)
          PontoDeAplicacaoResumoViewModel.fromEntity(
            ponto,
            aplicadorNome: nomesPorAplicadorId[ponto.aplicadorId],
          ),
      ];
      emit(
        state.copyWith(
          items: _filtrados(),
          filter: GeopragSearchField(
            hintText: 'Buscar por nome ou identificador...',
            onChanged: buscar,
          ),
          isLoading: false,
          limparErro: true,
          // Um recarregamento completo pode ter mudado o estado dos pontos
          // selecionados (é o que acontece logo após uma ação em lote) —
          // diferente da busca local (`buscar`), que só filtra o que já
          // está carregado e por isso preserva a seleção.
          idsSelecionados: const {},
        ),
      );
    } on EntidadeNaoEncontradaException catch (e) {
      emitError(e.mensagemAmigavel);
    } catch (e, stackTrace) {
      AppLogger.error('PontosDoBairroCubit._carregar', e, stackTrace);
      emitError(AppErrorMessages.carregamentoGenerico);
    }
  }

  void buscar(String query) {
    _busca = query.trim().toLowerCase();
    emitItems(_filtrados());
  }

  List<PontoDeAplicacaoResumoViewModel> _filtrados() {
    if (_busca.isEmpty) return _todos;
    return _todos
        .where(
          (ponto) =>
              ponto.nome.toLowerCase().contains(_busca) ||
              ponto.identificador.toLowerCase().contains(_busca),
        )
        .toList();
  }

  /// Pontos selecionados, independente do filtro de busca atual em
  /// [state.items] — a seleção sobrevive a um filtro que a esconda
  /// temporariamente (estilo Gmail).
  List<PontoDeAplicacaoResumoViewModel> get selecionados =>
      _todos.where((ponto) => state.idsSelecionados.contains(ponto.id)).toList();

  ReconciliacaoDoLote reconciliar(AcaoEmLote acao) =>
      reconciliarLote(acao: acao, selecionados: selecionados);

  Future<List<AplicadorOpcao>> listarAplicadoresDisponiveis() async => [
    for (final aplicador in await _aplicadorRepository.listar())
      AplicadorOpcao(id: aplicador.id, nome: aplicador.nome),
  ];

  /// Executa [acao] sobre um único ponto [id], usando os dados extras
  /// coletados em [confirmado] (agendamento ou aplicador, conforme a ação).
  /// Chamado pelo `BatchProgressDialog`, uma vez por id elegível.
  Future<void> executarUm(
    AcaoEmLote acao,
    String id,
    BatchReconcileConfirmado confirmado,
  ) {
    return switch (acao) {
      AcaoEmLote.ativar => _repository.ativar(id, confirmado.agendamento!),
      AcaoEmLote.desativar => _repository.desativar(id),
      AcaoEmLote.atribuirAplicador => _repository.atribuirAplicador(
        id,
        confirmado.aplicadorId!,
      ),
    };
  }

  /// Limpa a seleção e recarrega a lista — chamado depois que o
  /// `BatchProgressDialog` termina (com sucesso, falha ou uma mistura).
  Future<void> recarregarAposLote() async {
    limparSelecao();
    await _carregar();
  }
}
