import 'package:flutter/material.dart';

import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/widgets/base_form_screen.dart';
import '../../../src/widgets/geoprag_email_input.dart';
import '../../../src/widgets/geoprag_password_requirements.dart';
import '../../../src/widgets/geoprag_texto_input.dart';
import '../../autenticacao/core/admin_account.dart';
import '../../autenticacao/core/admin_auth_exceptions.dart';
import '../../autenticacao/core/admin_auth_repository.dart';
import '../core/administrador_repository.dart';

/// Edição dos próprios dados do administrador logado (GEOPRAG-148),
/// alcançada pelo dropdown de conta do rodapé do side menu (GEOPRAG-146).
///
/// Diferente das demais ações de [AdministradorRepository]
/// (desativar/reativar/rebaixar), não exige outro Administrador como
/// executor: qualquer administrador edita os próprios dados. Editar os
/// dados de **outro** administrador continua fora de escopo — confirmado
/// por Rafinha ao abrir esta issue ("não dá para editar mesmo").
///
/// Campos editáveis: nome e e-mail. CPF e cargo ficam fixos (cargo tem
/// fluxo próprio via solicitação de promoção). Troca de senha é opcional,
/// habilitada por um checkbox — exige a senha atual.
class EditarMeusDadosCubit extends BaseFormController {
  EditarMeusDadosCubit(
    this._administradorRepository,
    this._authRepository,
    this._contaAtual,
  ) : super(_initialModel()) {
    _nome = _contaAtual.nome;
    emailController.text = _contaAtual.email;
    _rebuildFields();
  }

  final AdministradorRepository _administradorRepository;
  final AdminAuthRepository _authRepository;
  final AdminAccount _contaAtual;

  final emailController = TextEditingController();

  String? _nome;

  bool _alterandoSenha = false;
  String? _senhaAtual;
  String? _novaSenha;
  bool _obscurarSenhaAtual = true;
  bool _obscurarNovaSenha = true;

  /// Preenchida após um [onSubmit] bem-sucedido — a tela lê isto para
  /// atualizar o `AdminSessionCubit`. O nome/e-mail exibidos no rodapé do
  /// side menu (GEOPRAG-146) precisam refletir a mudança imediatamente, sem
  /// exigir novo login.
  AdminAccount? contaAtualizada;

  static BaseFormModel _initialModel() => BaseFormModel(
    title: 'Meus dados',
    submitLabel: 'Salvar alterações',
    fields: const [],
  );

  void _rebuildFields() {
    if (isClosed) return;
    emit(state.copyWith(fields: _buildFields()));
  }

  List<BaseFormField> _buildFields() => [
    BaseFormField(
      label: 'Nome completo',
      field: GeopragTextoInput(
        label: 'Nome completo',
        initialValue: _nome,
        mensagemObrigatorio: 'Informe o nome completo.',
        onChanged: (valor) => _nome = valor,
      ),
    ),
    BaseFormField(
      label: 'E-mail institucional',
      // decoration vazio: sem isso, o rótulo interno padrão do widget
      // duplicaria o rótulo externo que BaseFormField já desenha acima
      // (mesmo motivo do CriarAdministradorCubit).
      field: GeopragEmailInput(
        controller: emailController,
        decoration: const InputDecoration(),
      ),
    ),
    BaseFormField(
      label: 'Segurança',
      field: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text('Também quero trocar minha senha'),
        value: _alterandoSenha,
        onChanged: (valor) {
          _alterandoSenha = valor ?? false;
          if (!_alterandoSenha) {
            _senhaAtual = null;
            _novaSenha = null;
          }
          _rebuildFields();
        },
      ),
    ),
    if (_alterandoSenha) ...[
      BaseFormField(
        label: 'Senha atual',
        field: TextFormField(
          initialValue: _senhaAtual,
          obscureText: _obscurarSenhaAtual,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurarSenhaAtual ? Icons.visibility_off : Icons.visibility,
              ),
              tooltip: _obscurarSenhaAtual ? 'Mostrar senha' : 'Ocultar senha',
              onPressed: () {
                _obscurarSenhaAtual = !_obscurarSenhaAtual;
                _rebuildFields();
              },
            ),
          ),
          onChanged: (valor) => _senhaAtual = valor,
          validator: (valor) => (valor == null || valor.isEmpty)
              ? 'Informe a senha atual.'
              : null,
        ),
      ),
      BaseFormField(
        label: 'Nova senha',
        field: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: _novaSenha,
              obscureText: _obscurarNovaSenha,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurarNovaSenha
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  tooltip: _obscurarNovaSenha
                      ? 'Mostrar senha'
                      : 'Ocultar senha',
                  onPressed: () {
                    _obscurarNovaSenha = !_obscurarNovaSenha;
                    _rebuildFields();
                  },
                ),
              ),
              onChanged: (valor) {
                _novaSenha = valor;
                _rebuildFields();
              },
              validator: (valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Informe a nova senha.';
                }
                final atende = GeopragPasswordRule.defaults().every(
                  (regra) => regra.isSatisfied(valor),
                );
                return atende ? null : 'A senha não atende aos requisitos.';
              },
            ),
            const SizedBox(height: 8),
            GeopragPasswordRequirements(password: _novaSenha ?? ''),
          ],
        ),
      ),
    ],
  ];

  @override
  Future<void> onSubmit() async {
    try {
      contaAtualizada = await _administradorRepository.editarPropriosDados(
        emailAtual: _contaAtual.email,
        nome: _nome!,
        novoEmail: emailController.text,
      );
    } on EntidadeDuplicadaException catch (e) {
      emitFeedback(AcaoFeedbackErro(e.mensagemAmigavel));
      return;
    } catch (e, stackTrace) {
      AppLogger.error('EditarMeusDadosCubit.onSubmit (dados)', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(AppErrorMessages.carregamentoGenerico),
      );
      return;
    }

    if (!_alterandoSenha) {
      emitFeedback(const AcaoFeedbackSucesso('Dados atualizados com sucesso.'));
      return;
    }

    try {
      await _authRepository.alterarSenha(
        senhaAtual: _senhaAtual!,
        novaSenha: _novaSenha!,
      );
      _alterandoSenha = false;
      _senhaAtual = null;
      _novaSenha = null;
      _rebuildFields();
      emitFeedback(
        const AcaoFeedbackSucesso('Dados e senha atualizados com sucesso.'),
      );
    } on InvalidCredentialsException {
      // Os dados (nome/e-mail) já foram salvos com sucesso no bloco acima —
      // só a senha não mudou. O usuário precisa saber que o salvamento foi
      // parcial, não que a operação inteira falhou.
      emitFeedback(
        const AcaoFeedbackErro(
          'Dados atualizados, mas a senha não foi alterada: senha atual incorreta.',
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('EditarMeusDadosCubit.onSubmit (senha)', e, stackTrace);
      emitFeedback(
        const AcaoFeedbackErro(
          'Dados atualizados, mas houve um erro ao trocar a senha.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    return super.close();
  }
}
