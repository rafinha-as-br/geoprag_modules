import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_data_nascimento_input.dart';
import '../core/distribuicao_repository.dart';
import 'distribuicao_view_model.dart';

/// Formulário de registro de nova saída de distribuição (GEOPRAG-24),
/// migrado para [BaseFormScreen] em GEOPRAG-104 — antes, os dropdowns de
/// produto/responsável já funcionavam, mas o botão final só navegava, sem
/// persistir nada (ver [DistribuicaoRepository.criar]).
///
/// Produtos e responsáveis são carregados de forma assíncrona ao construir o
/// Cubit; [isSubmitting] fica `true` nesse intervalo para desabilitar o botão
/// de envio até as opções chegarem — reaproveita o mesmo sinal do template
/// em vez de um estado de carregamento à parte.
class CadastroSaidaCubit extends BaseFormController {
  CadastroSaidaCubit(this._repository) : super(_initialModel()) {
    _carregarOpcoes();
  }

  final DistribuicaoRepository _repository;

  final quantidadeController = TextEditingController();

  List<ProdutoOpcaoViewModel> _produtos = [];
  List<ResponsavelOpcaoViewModel> _responsaveis = [];
  String? _produtoId;
  String? _responsavelId;
  String? _unidade;
  DateTime? _dataEntrega;

  static BaseFormModel _initialModel() => BaseFormModel(
    title: 'Ficha de Distribuição',
    submitLabel: 'Confirmar Saída e Gerar Documento',
    fields: const [],
    isSubmitting: true,
  );

  Future<void> _carregarOpcoes() async {
    try {
      final (produtos, responsaveis) = await (
        _repository.listarProdutosDisponiveis(),
        _repository.listarResponsaveisDisponiveis(),
      ).wait;
      _produtos = produtos.map(ProdutoOpcaoViewModel.fromEntity).toList();
      _responsaveis = responsaveis
          .map(ResponsavelOpcaoViewModel.fromEntity)
          .toList();
      emit(state.copyWith(fields: _buildFields(), isSubmitting: false));
    } on EntidadeNaoEncontradaException catch (e) {
      emit(state.copyWith(isSubmitting: false));
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('CadastroSaidaCubit._carregarOpcoes', e, stackTrace);
      emit(state.copyWith(isSubmitting: false));
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  void _rebuildFields() {
    emit(state.copyWith(fields: _buildFields()));
  }

  DropdownButtonFormField<String> _dropdownObrigatorio({
    required String? valor,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required String mensagemErro,
  }) => DropdownButtonFormField<String>(
    initialValue: valor,
    items: items,
    onChanged: onChanged,
    validator: (valor) => valor == null ? mensagemErro : null,
  );

  List<BaseFormField> _buildFields() => [
    BaseFormField(
      label: 'Produto/Lote',
      field: _dropdownObrigatorio(
        valor: _produtoId,
        items: [
          for (final produto in _produtos)
            DropdownMenuItem(value: produto.id, child: Text(produto.nomeExibicao)),
        ],
        onChanged: (valor) {
          _produtoId = valor;
          _rebuildFields();
        },
        mensagemErro: 'Selecione o produto.',
      ),
    ),
    BaseFormField(
      label: 'Responsável pelo Recebimento',
      field: _dropdownObrigatorio(
        valor: _responsavelId,
        items: [
          for (final responsavel in _responsaveis)
            DropdownMenuItem(
              value: responsavel.id,
              child: Text('${responsavel.nome} - ${responsavel.bairro}'),
            ),
        ],
        onChanged: (valor) {
          _responsavelId = valor;
          _rebuildFields();
        },
        mensagemErro: 'Selecione o responsável.',
      ),
    ),
    BaseFormField(
      label: 'Quantidade',
      field: TextFormField(
        controller: quantidadeController,
        decoration: const InputDecoration(suffixText: 'Litros/Kg'),
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
      label: 'Unidade',
      field: _dropdownObrigatorio(
        valor: _unidade,
        items: const [
          DropdownMenuItem(value: 'Litros', child: Text('Litros')),
          DropdownMenuItem(value: 'Kg', child: Text('Kg')),
        ],
        onChanged: (valor) {
          _unidade = valor;
          _rebuildFields();
        },
        mensagemErro: 'Selecione a unidade.',
      ),
    ),
    BaseFormField(
      label: 'Data da Entrega',
      // A data de entrega pode ser futura (agendamento) — sobrescreve o
      // intervalo padrão do widget (pensado para data de nascimento, só até
      // hoje) para liberar datas à frente.
      field: GeopragDataNascimentoInput(
        value: _dataEntrega,
        onChanged: (data) {
          _dataEntrega = data;
          _rebuildFields();
        },
        decoration: const InputDecoration(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        validator: (_) =>
            _dataEntrega == null ? 'Informe a data da entrega.' : null,
      ),
    ),
  ];

  @override
  Future<void> onSubmit() async {
    try {
      final responsavel = _responsaveis.firstWhere(
        (r) => r.id == _responsavelId,
        orElse: () => throw StateError(
          'Responsável "$_responsavelId" não está entre as opções carregadas.',
        ),
      );
      await _repository.criar(
        produtoId: _produtoId!,
        quantidade: int.parse(quantidadeController.text),
        unidade: _unidade!,
        dataEntrega: _dataEntrega!,
        responsavel: responsavel.nome,
        bairroResponsavel: responsavel.bairro,
      );
      emitFeedback(const AcaoFeedbackSucesso('Saída registrada com sucesso.'));
    } catch (e, stackTrace) {
      AppLogger.error('CadastroSaidaCubit.onSubmit', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  @override
  Future<void> close() {
    quantidadeController.dispose();
    return super.close();
  }
}
