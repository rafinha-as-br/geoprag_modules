import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/utils/form_validators.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_data_nascimento_input.dart';
import '../core/licitacao_repository.dart';

/// Formulário de registro de licitação/edital homologado (GEOPRAG-105),
/// migrado para [BaseFormScreen] — antes, `CadastroLicitacaoScreen` era
/// puramente decorativa (sem `GlobalKey<FormState>`, sem validators, sem
/// `TextEditingController`, texto digitado descartado).
class CriarLicitacaoCubit extends BaseFormController {
  CriarLicitacaoCubit(this._repository) : super(_initialModel()) {
    _rebuildFields();
  }

  final LicitacaoRepository _repository;

  final numeroAnoController = TextEditingController();
  final fornecedorController = TextEditingController();
  final objetoController = TextEditingController();
  final valorController = TextEditingController();

  DateTime? _dataHomologacao;

  static BaseFormModel _initialModel() => BaseFormModel(
    title: 'Nova Licitação/Edital',
    submitLabel: 'Salvar Licitação',
    fields: const [],
  );

  void _rebuildFields() {
    emit(state.copyWith(fields: _buildFields()));
  }

  List<BaseFormField> _buildFields() => [
    BaseFormField(
      label: 'Número e Ano (Ex: Pregão 01/2026)',
      field: TextFormField(
        controller: numeroAnoController,
        validator: (value) =>
            validarObrigatorio(value, 'Informe o número e ano.'),
      ),
    ),
    BaseFormField(
      label: 'Fornecedor Vencedor (Empresa)',
      field: TextFormField(
        controller: fornecedorController,
        validator: (value) =>
            validarObrigatorio(value, 'Informe o fornecedor vencedor.'),
      ),
    ),
    BaseFormField(
      label: 'Objeto Licitado (Descrição)',
      field: TextFormField(
        controller: objetoController,
        validator: (value) =>
            validarObrigatorio(value, 'Informe o objeto licitado.'),
      ),
    ),
    BaseFormField(
      label: 'Valor Total (R\$)',
      field: TextFormField(
        controller: valorController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: validarNumeroPositivo,
      ),
    ),
    BaseFormField(
      label: 'Data da Homologação',
      field: GeopragDataNascimentoInput(
        value: _dataHomologacao,
        onChanged: (data) {
          _dataHomologacao = data;
          _rebuildFields();
        },
        decoration: const InputDecoration(),
        validator: (_) =>
            _dataHomologacao == null ? 'Informe a data da homologação.' : null,
      ),
    ),
  ];

  @override
  Future<void> onSubmit() async {
    try {
      await _repository.criar(
        numeroAno: numeroAnoController.text,
        fornecedorVencedor: fornecedorController.text,
        objetoLicitado: objetoController.text,
        valorTotal: double.parse(valorController.text.replaceAll(',', '.')),
        dataHomologacao: _dataHomologacao!,
      );
      emitFeedback(const AcaoFeedbackSucesso('Licitação registrada com sucesso.'));
    } catch (e, stackTrace) {
      AppLogger.error('CriarLicitacaoCubit.onSubmit', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  @override
  Future<void> close() {
    numeroAnoController.dispose();
    fornecedorController.dispose();
    objetoController.dispose();
    valorController.dispose();
    return super.close();
  }
}
