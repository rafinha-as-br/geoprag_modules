import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/widgets/base_list_screen.dart';
import '../../autenticacao/core/admin_navigator.dart';
import '../../gerenciamento_de_administradores/presentation/widgets/geoprag_data_table.dart';
import '../core/produto_repository.dart';
import 'produto_view_model.dart';

/// Carrega a listagem de fórmulas de dosagem de BTI vinculadas aos produtos
/// do fabricante, exibida em `FormulaDeDosagemScreen` (migrada para
/// `BaseListScreen` em GEOPRAG-90).
class FormulasDosagemCubit
    extends BaseListScreenController<FormulaDosagemViewModel> {
  FormulasDosagemCubit(this._repository) : super(_initialModel()) {
    _carregar();
  }

  final ProdutoRepository _repository;

  static BaseListScreenModel<FormulaDosagemViewModel> _initialModel() {
    return BaseListScreenModel<FormulaDosagemViewModel>(
      title: 'Fórmulas de Dosagem por Produto',
      entityLabel: 'as fórmulas',
      emptyState: const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Nenhuma fórmula de dosagem cadastrada.'),
      ),
      filter: const Text(
        'Cada fórmula é repassada à API para calcular a dosagem exata com '
        'base na vazão medida do córrego.',
        style: TextStyle(color: Colors.grey),
      ),
      actions: [
        Builder(
          builder: (context) => ElevatedButton.icon(
            onPressed: () =>
                AdminNavigatorScope.of(context).toEstoqueFormulaNovo(),
            icon: const Icon(Icons.add),
            label: const Text('Nova Fórmula'),
          ),
        ),
      ],
      columns: [
        GeopragDataColumn(
          label: 'Produto',
          width: const FlexColumnWidth(2),
          cellBuilder: (context, f) => Text(f.produtoNome),
        ),
        GeopragDataColumn(
          label: 'Fator de Conversão',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, f) => Text('${f.fatorConversao} ml/m³/s'),
        ),
        GeopragDataColumn(
          label: 'Distância de Carreamento',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, f) =>
              Text('${f.distanciaCarreamento.toStringAsFixed(0)} m'),
        ),
        GeopragDataColumn(
          label: 'Fator de Correção',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, f) => Text('${f.fatorCorrecao}'),
        ),
        GeopragDataColumn(
          label: 'Ações',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, f) =>
              // TODO(GEOPRAG-105 follow-up): CadastroFormulaScreen/
              // CriarFormulaCubit (GEOPRAG-105) já persistem de verdade, mas
              // só criam — abrir esta tela pré-preenchida para editar uma
              // fórmula existente fica para uma issue própria; até lá,
              // resubmeter "Nova Fórmula" para o mesmo produto atualiza a
              // fórmula existente em vez de duplicá-la (ver
              // ProdutoRepositoryImpl.criarFormula).
              IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {},
            tooltip: 'Editar',
          ),
        ),
      ],
    );
  }

  Future<void> _carregar() async {
    emitLoading();
    try {
      final formulas = await _repository.listarFormulas();
      emitItems(formulas.map(FormulaDosagemViewModel.fromEntity).toList());
    } on EntidadeNaoEncontradaException catch (e) {
      emitError(e.mensagemAmigavel);
    } catch (e, stackTrace) {
      AppLogger.error('FormulasDosagemCubit._carregar', e, stackTrace);
      emitError(AppErrorMessages.carregamentoGenerico);
    }
  }
}
