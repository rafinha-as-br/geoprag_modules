import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/base_list_screen.dart';
import '../../../src/widgets/geoprag_search_field.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../autenticacao/core/admin_navigator.dart';
import '../../gerenciamento_de_administradores/presentation/widgets/geoprag_data_table.dart';
import '../core/produto_repository.dart';
import 'produto_view_model.dart';

/// Carrega a listagem de Produtos em estoque para o [BaseListScreen]
/// (migrado do dashboard de estoque em GEOPRAG-90).
class ProdutosCubit extends BaseListScreenController<ProdutoResumoViewModel> {
  ProdutosCubit(this._repository) : super(_initialModel()) {
    emit(
      state.copyWith(
        filter: GeopragSearchField(
          hintText: 'Buscar produto por lote ou licitação...',
          onChanged: buscar,
        ),
      ),
    );
    _carregar();
  }

  final ProdutoRepository _repository;

  List<ProdutoResumoViewModel> _todos = [];
  String _busca = '';

  static BaseListScreenModel<ProdutoResumoViewModel> _initialModel() {
    return BaseListScreenModel<ProdutoResumoViewModel>(
      title: 'Inventário Geral',
      entityLabel: 'os produtos',
      emptyState: const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Nenhum produto encontrado.'),
      ),
      actions: [
        Builder(
          builder: (context) => ElevatedButton.icon(
            onPressed: () =>
                AdminNavigatorScope.of(context).toEstoqueFormula(),
            icon: const Icon(Icons.calculate),
            label: const Text('Fórmula de Dosagem'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        Builder(
          builder: (context) => ElevatedButton.icon(
            onPressed: () =>
                AdminNavigatorScope.of(context).toEstoqueLicitacao(),
            icon: const Icon(Icons.description),
            label: const Text('Nova Licitação'),
          ),
        ),
        Builder(
          builder: (context) => ElevatedButton.icon(
            onPressed: () =>
                AdminNavigatorScope.of(context).toEstoqueProduto(),
            icon: const Icon(Icons.add_box),
            label: const Text('Registrar Entrada'),
          ),
        ),
      ],
      columns: [
        GeopragDataColumn(
          label: 'Produto / Lote',
          width: const FlexColumnWidth(2),
          cellBuilder: (context, p) => Text('${p.nome} - Lote ${p.lote}'),
        ),
        GeopragDataColumn(
          label: 'Licitação',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, p) => Text(p.licitacao),
        ),
        GeopragDataColumn(
          label: 'Estoque Atual',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, p) => Text('${p.quantidade} ${p.unidadeMedida}'),
        ),
        GeopragDataColumn(
          label: 'Status',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, p) {
            final statusExibicao = _statusExibicao(p);
            return GeopragStatusBadge(
              status: statusExibicao.status,
              label: statusExibicao.label,
              dense: true,
            );
          },
        ),
        GeopragDataColumn(
          label: 'Ações',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, p) => IconButton(
            icon: const Icon(Icons.visibility, color: Colors.blue),
            onPressed: () =>
                AdminNavigatorScope.of(context).toEstoqueVisualizacao(p.id),
          ),
        ),
      ],
    );
  }

  Future<void> _carregar() async {
    emitLoading();
    try {
      _todos = (await _repository.listar())
          .map(ProdutoResumoViewModel.fromEntity)
          .toList();
      emitItems(_filtrados());
    } on EntidadeNaoEncontradaException catch (e) {
      emitError(e.mensagemAmigavel);
    } catch (e, stackTrace) {
      AppLogger.error('ProdutosCubit._carregar', e, stackTrace);
      emitError(AppErrorMessages.carregamentoGenerico);
    }
  }

  /// Filtra a listagem carregada por nome, lote ou licitação — acionado
  /// pelo `GeopragSearchField` do slot `filter` do model.
  void buscar(String query) {
    _busca = query.trim().toLowerCase();
    emitItems(_filtrados());
  }

  List<ProdutoResumoViewModel> _filtrados() {
    if (_busca.isEmpty) return _todos;
    return _todos
        .where(
          (p) =>
              p.nome.toLowerCase().contains(_busca) ||
              p.lote.toLowerCase().contains(_busca) ||
              p.licitacao.toLowerCase().contains(_busca),
        )
        .toList();
  }

  /// Deriva o status visual (cor + rótulo do badge) exibido na listagem a
  /// partir da quantidade em estoque e da validade do lote.
  ///
  /// TODO(GEOPRAG-24): regra de "próximo do vencimento" (30 dias) é uma
  /// aproximação de UI enquanto não há parâmetro configurável vindo do
  /// backend.
  static ({GeopragStatus status, String label}) _statusExibicao(
    ProdutoResumoViewModel produto,
  ) {
    if (produto.quantidade <= 0) {
      return (status: GeopragStatus.atrasado, label: 'Esgotado');
    }
    final agora = DateTime.now();
    if (produto.dataValidade.isBefore(agora)) {
      return (status: GeopragStatus.atrasado, label: 'Vencido');
    }
    if (produto.dataValidade.difference(agora).inDays <= 30) {
      return (status: GeopragStatus.denuncia, label: 'Perto do Venc.');
    }
    return (status: GeopragStatus.emDia, label: 'Em estoque');
  }
}
