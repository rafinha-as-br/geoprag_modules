import 'package:flutter/material.dart';

import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/widgets/base_list_screen.dart';
import '../../autenticacao/core/admin_navigator.dart';
import '../../gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import '../core/admin_ponto_de_aplicacao_repository.dart';
import 'ponto_de_aplicacao_view_model.dart';
import 'widgets/painel_do_dashboard.dart';
import 'widgets/ponto_de_aplicacao_colunas.dart';

/// Carrega o panorama de todos os Pontos de Aplicação do município para o
/// [BaseListScreen] do dashboard de Gestão de Aplicações.
///
/// Pontos desativados ficam fora da listagem por padrão: são cadastros fora
/// de operação, e mostrá-los junto com os demais esconderia o que está
/// realmente ativo. O checkbox "incluir desativados" traz de volta quem
/// precisa auditá-los.
class PontosDeAplicacaoCubit
    extends BaseListScreenController<PontoDeAplicacaoResumoViewModel> {
  PontosDeAplicacaoCubit(this._repository, this._aplicadorRepository)
    : super(_initialModel()) {
    _carregar();
  }

  final AdminPontoDeAplicacaoRepository _repository;
  final AplicadorRepository _aplicadorRepository;

  List<PontoDeAplicacaoResumoViewModel> _todos = [];
  String _busca = '';
  EstadoPontoDeAplicacao? _estado;
  bool _incluirDesativados = false;

  static BaseListScreenModel<PontoDeAplicacaoResumoViewModel>
  _initialModel() {
    return BaseListScreenModel<PontoDeAplicacaoResumoViewModel>(
      title: 'Gestão de Aplicações',
      entityLabel: 'os pontos de aplicação',
      emptyState: const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Nenhum ponto de aplicação encontrado.'),
      ),
      actions: [
        Builder(
          builder: (context) => ElevatedButton.icon(
            onPressed: () =>
                AdminNavigatorScope.of(context).toCriarPontoDeAplicacao(),
            icon: const Icon(Icons.add_location_alt),
            label: const Text('Novo Ponto'),
          ),
        ),
      ],
      columns: colunasDePontoDeAplicacao(exibirBairro: true),
      onRowTap: (context, ponto) =>
          AdminNavigatorScope.of(context).toAplicacaoDetalhes(ponto.id),
    );
  }

  Future<void> _carregar() async {
    emitLoading();
    try {
      final pontos = await _repository.listar();
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
      _emitirListagem();
    } on EntidadeNaoEncontradaException catch (e) {
      emitError(e.mensagemAmigavel);
    } catch (e, stackTrace) {
      AppLogger.error('PontosDeAplicacaoCubit._carregar', e, stackTrace);
      emitError(AppErrorMessages.carregamentoGenerico);
    }
  }

  void buscar(String query) {
    _busca = query.trim().toLowerCase();
    _emitirListagem();
  }

  void filtrarPorEstado(EstadoPontoDeAplicacao? estado) {
    _estado = estado;
    _emitirListagem();
  }

  void alternarIncluirDesativados(bool incluir) {
    _incluirDesativados = incluir;
    _emitirListagem();
  }

  /// Emite listagem e painel juntos: o painel exibe alertas e cobertura
  /// derivados da carga completa, então ele precisa ser remontado sempre que
  /// os dados mudam — não só na construção do Cubit.
  void _emitirListagem() {
    emit(
      state.copyWith(
        items: _filtrados(),
        filter: PainelDoDashboard(
          alertas: _todos.where((ponto) => ponto.ativoSemRegistro).toList(),
          cobertura: _cobertura(),
          incluirDesativados: _incluirDesativados,
          estadoSelecionado: _estado,
          onBuscar: buscar,
          onFiltrarPorEstado: filtrarPorEstado,
          onAlternarIncluirDesativados: alternarIncluirDesativados,
        ),
        isLoading: false,
        limparErro: true,
      ),
    );
  }

  List<PontoDeAplicacaoResumoViewModel> _filtrados() {
    return _todos.where((ponto) {
      if (!_incluirDesativados && ponto.desativado) return false;
      if (_estado != null && ponto.estado != _estado) return false;
      if (_busca.isEmpty) return true;
      return ponto.nome.toLowerCase().contains(_busca) ||
          ponto.identificador.toLowerCase().contains(_busca) ||
          ponto.bairro.toLowerCase().contains(_busca);
    }).toList();
  }

  /// Agrega os pontos por bairro para o mapa de cobertura. Sempre sobre a
  /// carga completa, e não sobre [_filtrados]: o mapa mostra a cobertura do
  /// município, não o recorte que o usuário está olhando na tabela.
  List<CoberturaDeBairroViewModel> _cobertura() {
    final porBairro = <String, List<PontoDeAplicacaoResumoViewModel>>{};
    for (final ponto in _todos) {
      porBairro.putIfAbsent(ponto.bairro, () => []).add(ponto);
    }
    final cobertura = [
      for (final entrada in porBairro.entries)
        CoberturaDeBairroViewModel(
          bairro: entrada.key,
          totalDePontos: entrada.value.length,
          pontosAtivos: entrada.value
              .where((ponto) => ponto.estado == EstadoPontoDeAplicacao.ativa)
              .length,
          pontosComAlerta: entrada.value
              .where((ponto) => ponto.ativoSemRegistro)
              .length,
        ),
    ];
    cobertura.sort((a, b) => a.bairro.compareTo(b.bairro));
    return cobertura;
  }
}
