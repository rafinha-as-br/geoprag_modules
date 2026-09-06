import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/widgets/base_list_screen.dart';
import '../../../src/widgets/geoprag_search_field.dart';
import '../../autenticacao/core/admin_navigator.dart';
import '../../gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import '../core/admin_ponto_de_aplicacao_repository.dart';
import 'ponto_de_aplicacao_view_model.dart';
import 'widgets/ponto_de_aplicacao_colunas.dart';

/// Lista os Pontos de Aplicação de um bairro específico, aberta a partir da
/// legenda do mapa no dashboard.
///
/// Diferente do dashboard, aqui não há filtro de estado nem checkbox de
/// desativados: esta tela é o recorte de um bairro, e esconder parte dele
/// deixaria o administrador sem a visão completa do que existe ali.
class PontosDoBairroCubit
    extends BaseListScreenController<PontoDeAplicacaoResumoViewModel> {
  PontosDoBairroCubit(this._repository, this._aplicadorRepository, this._bairro)
    : super(_initialModel(_bairro)) {
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
}
