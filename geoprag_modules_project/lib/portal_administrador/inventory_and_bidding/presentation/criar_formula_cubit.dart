import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/utils/form_validators.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_dropdown_obrigatorio.dart';
import '../core/produto.dart';
import '../core/produto_repository.dart';

/// Formulário de cadastro da fórmula de dosagem de BTI de um produto do
/// fabricante (GEOPRAG-105), migrado para [BaseFormScreen] — antes,
/// `CadastroFormulaScreen` era puramente decorativa: nenhum campo (nem o
/// seletor de produto, que faltava por completo) era salvo em lugar nenhum.
///
/// Produtos disponíveis são carregados de forma assíncrona ao construir o
/// Cubit — mesmo padrão do `CadastroSaidaCubit` (GEOPRAG-104).
class CriarFormulaCubit extends BaseFormController {
  CriarFormulaCubit(this._repository) : super(_initialModel()) {
    _carregarProdutos();
  }

  final ProdutoRepository _repository;

  final fatorConversaoController = TextEditingController(text: '1.5');
  final distanciaCarreamentoController = TextEditingController(text: '150');
  final fatorCorrecaoController = TextEditingController(text: '1.2');

  List<Produto> _produtos = [];
  String? _produtoId;

  static BaseFormModel _initialModel() => BaseFormModel(
    title: 'Configuração Base de Dosagem',
    description:
        'Esta fórmula é repassada à API para calcular a dosagem exata com '
        'base na Vazão (Largura x Profundidade x Velocidade) do córrego.',
    submitLabel: 'Salvar Nova Fórmula e Atualizar API',
    fields: const [],
    width: 700,
  );

  Future<void> _carregarProdutos() async {
    try {
      _produtos = await _repository.listar();
      _rebuildFields();
    } catch (e, stackTrace) {
      AppLogger.error('CriarFormulaCubit._carregarProdutos', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  void _rebuildFields() {
    emit(state.copyWith(fields: _buildFields()));
  }

  List<BaseFormField> _buildFields() => [
    BaseFormField(
      label: 'Produto',
      field: dropdownObrigatorio(
        valor: _produtoId,
        items: [
          for (final produto in _produtos)
            DropdownMenuItem(
              value: produto.id,
              child: Text('${produto.nome} - Lote ${produto.lote}'),
            ),
        ],
        onChanged: (valor) {
          _produtoId = valor;
          _rebuildFields();
        },
        mensagemErro: 'Selecione o produto.',
      ),
    ),
    BaseFormField(
      label: 'Fator de Conversão BTI (ml por m³/s)',
      field: TextFormField(
        controller: fatorConversaoController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: validarNumeroPositivo,
      ),
    ),
    BaseFormField(
      label: 'Distância de Carreamento Esperada (m)',
      field: TextFormField(
        controller: distanciaCarreamentoController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: validarNumeroPositivo,
      ),
    ),
    BaseFormField(
      label: 'Fator de Correção (Água Suja/Orgânica)',
      field: TextFormField(
        controller: fatorCorrecaoController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: validarNumeroPositivo,
      ),
    ),
  ];

  @override
  Future<void> onSubmit() async {
    try {
      await _repository.criarFormula(
        produtoId: _produtoId!,
        fatorConversao: double.parse(
          fatorConversaoController.text.replaceAll(',', '.'),
        ),
        distanciaCarreamento: double.parse(
          distanciaCarreamentoController.text.replaceAll(',', '.'),
        ),
        fatorCorrecao: double.parse(
          fatorCorrecaoController.text.replaceAll(',', '.'),
        ),
      );
      emitFeedback(const AcaoFeedbackSucesso('Fórmula salva com sucesso.'));
    } catch (e, stackTrace) {
      AppLogger.error('CriarFormulaCubit.onSubmit', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  @override
  Future<void> close() {
    fatorConversaoController.dispose();
    distanciaCarreamentoController.dispose();
    fatorCorrecaoController.dispose();
    return super.close();
  }
}
