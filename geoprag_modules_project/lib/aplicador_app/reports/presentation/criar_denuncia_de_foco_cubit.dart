import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../core/denuncia_de_foco.dart';
import '../core/denuncia_de_foco_repository.dart';
import 'denuncia_de_foco_view_model.dart';

/// Formulário de registro de denúncia de foco de infestação (GEOPRAG-107),
/// migrado para [BaseFormScreen] — antes, `CadastroDoFocoScreen` tinha um
/// `_formKey` declarado mas nunca validado, e o botão "Enviar Denúncia" só
/// mostrava um `SnackBar` fixo sem chamar [DenunciaDeFocoRepository].
class CriarDenunciaDeFocoCubit extends BaseFormController {
  CriarDenunciaDeFocoCubit(this._repository) : super(_initialModel()) {
    _rebuildFields();
  }

  final DenunciaDeFocoRepository _repository;

  final localController = TextEditingController();
  final observacoesController = TextEditingController();

  NivelInfestacaoFoco _nivelInfestacao = NivelInfestacaoFoco.medio;

  static BaseFormModel _initialModel() => BaseFormModel(
    title: 'Nova Denúncia',
    description:
        'Localização atual capturada automaticamente para a vistoria.',
    submitLabel: 'Enviar Denúncia',
    fields: const [],
  );

  void _rebuildFields() {
    emit(state.copyWith(fields: _buildFields()));
  }

  List<BaseFormField> _buildFields() => [
    BaseFormField(
      label: 'Nível de Infestação',
      field: DropdownButtonFormField<NivelInfestacaoFoco>(
        initialValue: _nivelInfestacao,
        items: [
          for (final nivel in NivelInfestacaoFoco.values)
            DropdownMenuItem(
              value: nivel,
              child: Text(DenunciaDeFocoViewModel.labelDoNivel(nivel)),
            ),
        ],
        onChanged: (valor) {
          _nivelInfestacao = valor!;
          _rebuildFields();
        },
      ),
    ),
    BaseFormField(
      label: 'Descrição do local (Ex: perto da ponte)',
      field: TextFormField(
        controller: localController,
        validator: (value) => (value == null || value.isEmpty)
            ? 'Informe a descrição do local.'
            : null,
      ),
    ),
    BaseFormField(
      label: 'Observações extras (opcional)',
      field: TextFormField(controller: observacoesController, maxLines: 4),
    ),
  ];

  @override
  Future<void> onSubmit() async {
    try {
      await _repository.registrar(
        nivelInfestacao: _nivelInfestacao,
        localDescricao: localController.text,
        observacoes: observacoesController.text.isEmpty
            ? null
            : observacoesController.text,
      );
      emitFeedback(const AcaoFeedbackSucesso('Denúncia enviada com sucesso!'));
    } catch (e, stackTrace) {
      AppLogger.error('CriarDenunciaDeFocoCubit.onSubmit', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  @override
  Future<void> close() {
    localController.dispose();
    observacoesController.dispose();
    return super.close();
  }
}
