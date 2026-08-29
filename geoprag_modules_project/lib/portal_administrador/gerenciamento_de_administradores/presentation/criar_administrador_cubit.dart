import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/utils/senha_inicial_generator.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_cpf_input.dart';
import '../../../src/widgets/geoprag_data_nascimento_input.dart';
import '../../../src/widgets/geoprag_email_input.dart';
import '../../../src/widgets/geoprag_sexo_input.dart';
import '../core/administrador_repository.dart';

/// Formulário de criação de novo administrador (GEOPRAG-36), migrado para
/// [BaseFormScreen] em GEOPRAG-103 — o resultado sempre nasce
/// Sub-Administrador, ver [AdministradorRepository].
///
/// [senhaGerada] fica fora do [BaseFormModel] pelo mesmo motivo do
/// `CriarAplicadorCubit` (GEOPRAG-102): o contrato de feedback do template só
/// carrega uma mensagem de texto, e a senha inicial precisa de um dialog
/// modal próprio (`GeopragSenhaGeradaDialog`).
class CriarAdministradorCubit extends BaseFormController {
  CriarAdministradorCubit(this._repository) : super(_initialModel()) {
    _rebuildFields();
  }

  final AdministradorRepository _repository;

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final cpfController = TextEditingController();

  String? _sexo;
  DateTime? _dataNascimento;

  String? senhaGerada;

  static BaseFormModel _initialModel() => BaseFormModel(
    title: 'Registrar Novo Administrador',
    description:
        'Novo cadastro nasce como Sub-Administrador. A elevação a '
        'Administrador só ocorre por promoção, em outro fluxo.',
    submitLabel: 'Registrar Sub-Administrador',
    fields: const [],
  );

  void _rebuildFields() {
    emit(state.copyWith(fields: _buildFields()));
  }

  List<BaseFormField> _buildFields() => [
    BaseFormField(
      label: 'Nome completo',
      field: TextFormField(
        controller: nomeController,
        validator: (value) => (value == null || value.isEmpty)
            ? 'Informe o nome completo.'
            : null,
      ),
    ),
    BaseFormField(
      label: 'E-mail institucional',
      // decoration vazio: sem isso, o rótulo interno padrão do widget
      // ("E-mail") duplicaria o rótulo externo que BaseFormScreen já
      // desenha acima do campo.
      field: GeopragEmailInput(
        controller: emailController,
        decoration: const InputDecoration(),
      ),
    ),
    BaseFormField(
      label: 'CPF',
      field: GeopragCpfInput(
        controller: cpfController,
        decoration: const InputDecoration(hintText: '000.000.000-00'),
        validator: (value) => (value == null || value.length != 14)
            ? 'Informe um CPF válido.'
            : null,
      ),
    ),
    BaseFormField(
      label: 'Data de nascimento',
      field: GeopragDataNascimentoInput(
        value: _dataNascimento,
        onChanged: (data) {
          _dataNascimento = data;
          _rebuildFields();
        },
        decoration: const InputDecoration(),
        validator: (_) =>
            _dataNascimento == null ? 'Informe a data de nascimento.' : null,
      ),
    ),
    BaseFormField(
      label: 'Sexo',
      field: GeopragSexoInput(
        value: _sexo,
        onChanged: (value) {
          _sexo = value;
          _rebuildFields();
        },
        decoration: const InputDecoration(),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Informe o sexo.' : null,
      ),
    ),
  ];

  @override
  Future<void> onSubmit() async {
    // Limpa uma senha de um sucesso anterior antes de tentar de novo — sem
    // isso, um retry que falha deixaria a senha do envio anterior parada em
    // `senhaGerada`, pronta para vazar caso algo volte a lê-la por engano.
    senhaGerada = null;
    try {
      await _repository.criar(
        email: emailController.text,
        nome: nomeController.text,
        cpf: cpfController.text,
        dataNascimento: _dataNascimento!,
        sexo: _sexo!,
      );
      senhaGerada = gerarSenhaInicial(
        nome: nomeController.text,
        dataNascimento: _dataNascimento!,
      );
      emitFeedback(
        const AcaoFeedbackSucesso('Administrador cadastrado com sucesso.'),
      );
    } on EntidadeDuplicadaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('CriarAdministradorCubit.onSubmit', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
    }
  }

  @override
  Future<void> close() {
    nomeController.dispose();
    emailController.dispose();
    cpfController.dispose();
    return super.close();
  }
}
