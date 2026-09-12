import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/utils/senha_inicial_generator.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_cep_input.dart';
import '../../../src/widgets/geoprag_cpf_input.dart';
import '../../../src/widgets/geoprag_data_nascimento_input.dart';
import '../../../src/widgets/geoprag_email_input.dart';
import '../../../src/widgets/geoprag_sexo_input.dart';
import '../core/aplicador_repository.dart';

/// Formulário de criação de novo Aplicador (GEOPRAG-65), migrado para
/// [BaseFormScreen] em GEOPRAG-102. O cadastro nasce sempre `Ativo`, ver
/// [AplicadorRepository].
///
/// [senhaGerada] fica fora do [BaseFormModel] deliberadamente: o contrato de
/// feedback do template (`AcaoFeedback`) só carrega uma mensagem de texto, e
/// a senha inicial precisa ser exibida num dialog modal próprio
/// (`GeopragSenhaGeradaDialog`) com a string completa, não uma mensagem de
/// status. A tela lê este campo via `context.read` ao reagir ao feedback de
/// sucesso.
class CriarAplicadorCubit extends BaseFormController {
  CriarAplicadorCubit(this._repository) : super(_initialModel()) {
    _rebuildFields();
  }

  final AplicadorRepository _repository;

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final cpfController = TextEditingController();
  final cepController = TextEditingController();
  final ruaController = TextEditingController();
  final numeroController = TextEditingController();
  final complementoController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final ufController = TextEditingController();

  String? _sexo;
  DateTime? _dataNascimento;

  String? senhaGerada;

  static BaseFormModel _initialModel() => BaseFormModel(
    title: 'Novo Aplicador',
    description:
        'A senha inicial é gerada automaticamente e exibida ao salvar — '
        'repasse-a verbalmente e pessoalmente ao voluntário.',
    submitLabel: 'Registrar Aplicador',
    fields: const [],
  );

  void _rebuildFields() {
    emit(state.copyWith(fields: _buildFields()));
  }

  static TextFormField _obrigatorio(
    TextEditingController controller,
    String mensagemErro, {
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) => TextFormField(
    controller: controller,
    maxLength: maxLength,
    textCapitalization: textCapitalization,
    validator: (value) =>
        (value == null || value.isEmpty) ? mensagemErro : null,
  );

  List<BaseFormField> _buildFields() => [
    BaseFormField(
      label: 'Nome completo',
      field: _obrigatorio(nomeController, 'Informe o nome completo.'),
    ),
    BaseFormField(
      label: 'E-mail',
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
        validator: (value) =>
            (value == null || value.length != 14) ? 'Informe um CPF válido.' : null,
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
    BaseFormField(
      label: 'CEP',
      field: GeopragCepInput(
        controller: cepController,
        decoration: const InputDecoration(hintText: '00000-000'),
      ),
    ),
    BaseFormField(
      label: 'Rua',
      field: _obrigatorio(ruaController, 'Informe a rua.'),
    ),
    BaseFormField(
      label: 'Número',
      field: _obrigatorio(numeroController, 'Informe o número.'),
    ),
    BaseFormField(
      label: 'Complemento (opcional)',
      field: TextFormField(controller: complementoController),
    ),
    BaseFormField(
      label: 'Bairro',
      field: _obrigatorio(bairroController, 'Informe o bairro.'),
    ),
    BaseFormField(
      label: 'Cidade',
      field: _obrigatorio(cidadeController, 'Informe a cidade.'),
    ),
    BaseFormField(
      label: 'UF',
      field: _obrigatorio(
        ufController,
        'Informe a UF.',
        maxLength: 2,
        textCapitalization: TextCapitalization.characters,
      ),
    ),
  ];

  @override
  Future<void> onSubmit() async {
    try {
      await _repository.criar(
        email: emailController.text,
        nome: nomeController.text,
        cpf: cpfController.text,
        dataNascimento: _dataNascimento!,
        sexo: _sexo!,
        cep: cepController.text,
        rua: ruaController.text,
        numero: numeroController.text,
        complemento: complementoController.text.isEmpty
            ? null
            : complementoController.text,
        bairro: bairroController.text,
        cidade: cidadeController.text,
        uf: ufController.text,
      );
      senhaGerada = gerarSenhaInicial(
        nome: nomeController.text,
        dataNascimento: _dataNascimento!,
      );
      emitFeedback(
        const AcaoFeedbackSucesso('Aplicador cadastrado com sucesso.'),
      );
    } on EntidadeDuplicadaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('CriarAplicadorCubit.onSubmit', e, stackTrace);
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
    cepController.dispose();
    ruaController.dispose();
    numeroController.dispose();
    complementoController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    ufController.dispose();
    return super.close();
  }
}
