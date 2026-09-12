import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/widgets/base_list_screen.dart';
import '../../../src/widgets/geoprag_filter_dropdown.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../autenticacao/core/admin_navigator.dart';
import '../../gerenciamento_de_administradores/presentation/widgets/geoprag_data_table.dart';
import '../core/denuncia_repository.dart';
import 'denuncia_view_model.dart';

const _todosOsStatus = 'Todas';
const _todosOsNiveis = 'Todos';

const _opcoesStatus = [
  _todosOsStatus,
  'Recebida',
  'Equipe a Investigar',
  'Em Combate',
  'Resolvido',
];

const _opcoesNivel = [_todosOsNiveis, 'Alto'];

/// Panorama de triagem — visão rápida de todas as Denúncias, para a equipe
/// decidir o que priorizar (`dashboard_denuncias_admin_screen`, migrada
/// para `BaseListScreen` em GEOPRAG-90). Para a listagem completa e
/// pesquisável, ver [ListagemDenunciasController] — as duas telas
/// compartilham o mesmo [DenunciaRepository], mas cada uma injeta sua
/// própria instância e mantém seu próprio filtro/colunas, por decisão de
/// Rafinha (contrato do template é 1 controller por `BaseListScreen`).
class TriagemDenunciasController
    extends BaseListScreenController<DenunciaResumoViewModel> {
  TriagemDenunciasController(this._repository) : super(_initialModel()) {
    _emitFiltro();
    _carregar();
  }

  final DenunciaRepository _repository;

  List<DenunciaResumoViewModel> _todos = [];
  String _statusFiltro = _todosOsStatus;
  String _nivelFiltro = _todosOsNiveis;

  static BaseListScreenModel<DenunciaResumoViewModel> _initialModel() {
    return BaseListScreenModel<DenunciaResumoViewModel>(
      title: 'Triagem e Acompanhamento de Focos',
      entityLabel: 'as denúncias',
      emptyState: const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Nenhuma denúncia encontrada.'),
      ),
      actions: [
        Builder(
          builder: (context) => OutlinedButton.icon(
            onPressed: () =>
                AdminNavigatorScope.of(context).toDenunciasAdminListagem(),
            icon: const Icon(Icons.list_alt),
            label: const Text('Ver listagem completa'),
          ),
        ),
      ],
      columns: [
        GeopragDataColumn(
          label: 'Data',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, d) => Text(d.dataFormatada),
        ),
        GeopragDataColumn(
          label: 'Descrição do Local',
          width: const FlexColumnWidth(2),
          cellBuilder: (context, d) => Text(d.descricao),
        ),
        GeopragDataColumn(
          label: 'Nível',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, d) => Text(
            d.nivelInfestacao,
            style: TextStyle(
              color: corNivelInfestacao(d.nivelInfestacao),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GeopragDataColumn(
          label: 'Status',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, d) => GeopragStatusBadge(
            status: statusParaBadge(d.status),
            label: d.status,
            dense: true,
          ),
        ),
      ],
      // Clicar em qualquer ponto da linha abre o detalhe — não uma coluna de
      // ações separada (mesmo critério de GEOPRAG-90, validação GEOPRAG-118).
      onRowTap: (context, d) =>
          AdminNavigatorScope.of(context).toDenunciaAdminDetalhes(d.id),
    );
  }

  void _emitFiltro() {
    emit(
      state.copyWith(
        filter: Row(
          children: [
            Expanded(
              child: GeopragFilterDropdown(
                label: 'Filtrar por Status',
                options: _opcoesStatus,
                initialValue: _statusFiltro,
                onChanged: (v) {
                  _statusFiltro = v;
                  emitItems(_filtrados());
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GeopragFilterDropdown(
                label: 'Nível de Infestação',
                options: _opcoesNivel,
                initialValue: _nivelFiltro,
                onChanged: (v) {
                  _nivelFiltro = v;
                  emitItems(_filtrados());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _carregar() async {
    emitLoading();
    try {
      _todos = (await _repository.listar())
          .map(DenunciaResumoViewModel.fromEntity)
          .toList();
      emitItems(_filtrados());
    } on EntidadeNaoEncontradaException catch (e) {
      emitError(e.mensagemAmigavel);
    } catch (e, stackTrace) {
      AppLogger.error('TriagemDenunciasController._carregar', e, stackTrace);
      emitError(AppErrorMessages.carregamentoGenerico);
    }
  }

  List<DenunciaResumoViewModel> _filtrados() {
    return _todos.where((d) {
      final statusCombina =
          _statusFiltro == _todosOsStatus || d.status == _statusFiltro;
      final nivelCombina =
          _nivelFiltro == _todosOsNiveis || d.nivelInfestacao == _nivelFiltro;
      return statusCombina && nivelCombina;
    }).toList();
  }
}
