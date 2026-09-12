import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/widgets/base_list_screen.dart';
import '../../../src/widgets/geoprag_filter_dropdown.dart';
import '../../../src/widgets/geoprag_search_field.dart';
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

const _opcoesNivel = [_todosOsNiveis, 'Alto', 'Médio', 'Baixo'];

/// Listagem completa e pesquisável de todas as Denúncias registradas
/// (`listagem_de_denuncias_screen`, migrada para `BaseListScreen` em
/// GEOPRAG-90) — diferente do panorama de triagem em
/// [TriagemDenunciasController]. As duas telas compartilham o mesmo
/// [DenunciaRepository], mas cada uma injeta sua própria instância e mantém
/// seu próprio filtro/colunas, por decisão de Rafinha.
class ListagemDenunciasController
    extends BaseListScreenController<DenunciaResumoViewModel> {
  ListagemDenunciasController(this._repository) : super(_initialModel()) {
    _emitFiltro();
    _carregar();
  }

  final DenunciaRepository _repository;

  List<DenunciaResumoViewModel> _todos = [];
  String _busca = '';
  String _statusFiltro = _todosOsStatus;
  String _nivelFiltro = _todosOsNiveis;

  static BaseListScreenModel<DenunciaResumoViewModel> _initialModel() {
    return BaseListScreenModel<DenunciaResumoViewModel>(
      title: 'Todas as Denúncias Registradas',
      entityLabel: 'as denúncias',
      emptyState: const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Nenhuma denúncia encontrada para os filtros aplicados.'),
      ),
      columns: [
        GeopragDataColumn(
          label: 'Data',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, d) => Text(d.dataFormatada),
        ),
        GeopragDataColumn(
          label: 'Denunciante',
          width: const FlexColumnWidth(2),
          cellBuilder: (context, d) => Text(d.denunciante),
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
        GeopragDataColumn(
          label: 'Ações',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, d) => IconButton(
            icon: const Icon(Icons.visibility, color: Colors.blue),
            tooltip: 'Analisar e Tratar',
            onPressed: () =>
                AdminNavigatorScope.of(context).toDenunciaAdminDetalhes(d.id),
          ),
        ),
      ],
    );
  }

  void _emitFiltro() {
    emit(
      state.copyWith(
        filter: Row(
          children: [
            Expanded(
              flex: 2,
              child: GeopragSearchField(
                hintText: 'Buscar por denunciante ou descrição...',
                onChanged: (v) {
                  _busca = v.trim().toLowerCase();
                  emitItems(_filtrados());
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GeopragFilterDropdown(
                label: 'Status',
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
      AppLogger.error('ListagemDenunciasController._carregar', e, stackTrace);
      emitError(AppErrorMessages.carregamentoGenerico);
    }
  }

  List<DenunciaResumoViewModel> _filtrados() {
    return _todos.where((d) {
      final statusCombina =
          _statusFiltro == _todosOsStatus || d.status == _statusFiltro;
      final nivelCombina =
          _nivelFiltro == _todosOsNiveis || d.nivelInfestacao == _nivelFiltro;
      final buscaCombina =
          _busca.isEmpty ||
          d.denunciante.toLowerCase().contains(_busca) ||
          d.descricao.toLowerCase().contains(_busca);
      return statusCombina && nivelCombina && buscaCombina;
    }).toList();
  }
}
