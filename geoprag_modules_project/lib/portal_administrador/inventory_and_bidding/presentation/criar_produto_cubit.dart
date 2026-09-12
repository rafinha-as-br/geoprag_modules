import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/utils/form_validators.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_data_nascimento_input.dart';
import '../../../src/widgets/geoprag_dropdown_obrigatorio.dart';
import '../core/licitacao.dart';
import '../core/licitacao_repository.dart';
import '../core/produto_repository.dart';

/// Formulário de registro de entrada de produto/lote no estoque
/// (GEOPRAG-105), migrado para [BaseFormScreen] — antes,
/// `CadastroProdutoScreen` era puramente decorativa (sem
/// `GlobalKey<FormState>`, sem validators, sem `TextEditingController`,
/// dropdowns com `onChanged: (v) {}`).
///
/// Licitações disponíveis são carregadas de forma assíncrona ao construir o
/// Cubit — mesmo padrão do `CadastroSaidaCubit` (GEOPRAG-104). O fornecedor
/// do produto não é digitado: é o fornecedor vencedor da licitação vinculada.
class CriarProdutoCubit extends BaseFormController {
  CriarProdutoCubit(this._produtoRepository, this._licitacaoRepository)
    : super(_initialModel()) {
    _carregarLicitacoes();
  }

  final ProdutoRepository _produtoRepository;
  final LicitacaoRepository _licitacaoRepository;

  final nomeController = TextEditingController();
  final loteController = TextEditingController();
  final quantidadeController = TextEditingController();

  List<Licitacao> _licitacoes = [];
  String? _licitacaoId;
  DateTime? _dataValidade;
  String? _unidadeMedida;

  static BaseFormModel _initialModel() => BaseFormModel(
    title: 'Dados do Produto e Lote',
    submitLabel: 'Confirmar Entrada no Estoque',
    fields: const [],
  );

  Future<void> _carregarLicitacoes() async {
    try {
      _licitacoes = await _licitacaoRepository.listar();
      _rebuildFields();
    } catch (e, stackTrace) {
      AppLogger.error('CriarProdutoCubit._carregarLicitacoes', e, stackTrace);
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
      label: 'Licitação Vinculada',
      field: dropdownObrigatorio(
        valor: _licitacaoId,
        items: [
          for (final licitacao in _licitacoes)
            DropdownMenuItem(
              value: licitacao.id,
              child: Text(licitacao.numeroAno),
            ),
        ],
        onChanged: (valor) {
          _licitacaoId = valor;
          _rebuildFields();
        },
        mensagemErro: 'Selecione a licitação.',
      ),
    ),
    BaseFormField(
      label: 'Descrição Comercial do Produto',
      field: TextFormField(
        controller: nomeController,
        validator: (value) => validarObrigatorio(value, 'Informe o produto.'),
      ),
    ),
    BaseFormField(
      label: 'Nº do Lote',
      field: TextFormField(
        controller: loteController,
        validator: (value) => validarObrigatorio(value, 'Informe o lote.'),
      ),
    ),
    BaseFormField(
      label: 'Validade',
      field: GeopragDataNascimentoInput(
        value: _dataValidade,
        onChanged: (data) {
          _dataValidade = data;
          _rebuildFields();
        },
        decoration: const InputDecoration(),
        // Validade é sempre uma data futura em relação ao recebimento.
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        validator: (_) => _dataValidade == null ? 'Informe a validade.' : null,
      ),
    ),
    BaseFormField(
      label: 'Quantidade Recebida',
      field: TextFormField(
        controller: quantidadeController,
        keyboardType: TextInputType.number,
        validator: (value) {
          final quantidade = int.tryParse(value ?? '');
          return (quantidade == null || quantidade <= 0)
              ? 'Informe uma quantidade válida.'
              : null;
        },
      ),
    ),
    BaseFormField(
      label: 'Unidade de Medida',
      field: dropdownObrigatorio(
        valor: _unidadeMedida,
        items: const [
          DropdownMenuItem(value: 'Litros', child: Text('Litros (L)')),
          DropdownMenuItem(value: 'Kg', child: Text('Quilogramas (Kg)')),
        ],
        onChanged: (valor) {
          _unidadeMedida = valor;
          _rebuildFields();
        },
        mensagemErro: 'Selecione a unidade de medida.',
      ),
    ),
  ];

  @override
  Future<void> onSubmit() async {
    try {
      final licitacao = _licitacoes.firstWhere(
        (l) => l.id == _licitacaoId,
        orElse: () => throw StateError(
          'Licitação "$_licitacaoId" não está entre as opções carregadas.',
        ),
      );
      await _produtoRepository.registrarEntrada(
        nome: nomeController.text,
        lote: loteController.text,
        dataValidade: _dataValidade!,
        quantidade: int.parse(quantidadeController.text),
        unidadeMedida: _unidadeMedida!,
        licitacao: licitacao.numeroAno,
        fornecedor: licitacao.fornecedorVencedor,
      );
      emitFeedback(
        const AcaoFeedbackSucesso('Entrada registrada com sucesso.'),
      );
    } catch (e, stackTrace) {
      AppLogger.error('CriarProdutoCubit.onSubmit', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  @override
  Future<void> close() {
    nomeController.dispose();
    loteController.dispose();
    quantidadeController.dispose();
    return super.close();
  }
}
