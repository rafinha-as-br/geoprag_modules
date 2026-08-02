import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/widgets/geoprag_cpf_input.dart';
import '../../../src/widgets/geoprag_data_nascimento_input.dart';
import '../../../src/widgets/geoprag_sexo_input.dart';
import '../../autenticacao/core/admin_navigator.dart';
import '../../widgets/admin_scaffold.dart';
import 'criar_administrador_cubit.dart';
import 'criar_administrador_state.dart';

/// Formulário de criação de novo administrador (GEOPRAG-36). Acesso restrito
/// a quem tem cargo Administrador — o guard é aplicado no `redirect` do
/// GoRouter (`app_administrador/lib/main.dart`), não nesta tela.
///
/// Usa [AdminScaffold] como as demais telas do módulo — abre com o sidebar
/// comum, não como uma tela cheia isolada (feedback de revisão do PR #9).
///
/// O cargo do novo cadastro não é escolhido aqui: todo cadastro novo nasce
/// Sub-Administrador (ver [CriarAdministradorCubit]/`AdministradorRepository`).
class CriacaoDeAdministradorScreen extends StatefulWidget {
  const CriacaoDeAdministradorScreen({super.key});

  @override
  State<CriacaoDeAdministradorScreen> createState() =>
      _CriacaoDeAdministradorScreenState();
}

class _CriacaoDeAdministradorScreenState
    extends State<CriacaoDeAdministradorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _sexoController = TextEditingController();
  final _cepController = TextEditingController();
  DateTime? _dataNascimento;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _sexoController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  /// Senha inicial exibida uma única vez em [_SenhaGeradaBanner], logo após
  /// o cadastro ser salvo (GEOPRAG-61/68) — não é reexibida depois que a
  /// tela é fechada, nem persistida em nenhum outro lugar.
  String? _senhaGerada;

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/administradores/novo',
      appBar: AppBar(title: const Text('Registrar Novo Administrador')),
      body: BlocConsumer<CriarAdministradorCubit, CriarAdministradorState>(
        listener: (context, state) {
          if (state is CriarAdministradorSucesso) {
            // Não navega de volta imediatamente — a senha gerada precisa
            // ficar visível na tela até o Administrador confirmar que já
            // repassou ela verbalmente ao novo usuário (ver botão
            // "Concluir" em [_SenhaGeradaBanner]).
            setState(() => _senhaGerada = state.senhaGerada);
          } else if (state is CriarAdministradorErro) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final salvando = state is CriarAdministradorSalvando;
          return Stack(
            children: [
              _buildFormulario(context, salvando),
              if (_senhaGerada != null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: _SenhaGeradaBanner(
                    senha: _senhaGerada!,
                    onConcluir: () {
                      // Esta tela é sempre alcançada por push a partir do
                      // dashboard do módulo (`toCriarAdministrador`) —
                      // `.back()` volta pra lá, onde o cadastro recém-criado
                      // já aparece na listagem.
                      AdminNavigatorScope.of(context).back();
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormulario(BuildContext context, bool salvando) {
    return Center(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Novo cadastro nasce como Sub-Administrador. A '
                    'elevação a Administrador só ocorre por promoção, '
                    'em outro fluxo.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Informe o nome completo.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail institucional',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Informe o e-mail institucional.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  GeopragCpfInput(
                    controller: _cpfController,
                    decoration: const InputDecoration(
                      labelText: 'CPF',
                      hintText: '000.000.000-00',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.length != 14)
                        ? 'Informe um CPF válido.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  GeopragDataNascimentoInput(
                    value: _dataNascimento,
                    onChanged: (data) => setState(() => _dataNascimento = data),
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento',
                      border: OutlineInputBorder(),
                    ),
                    validator: (_) => _dataNascimento == null
                        ? 'Informe a data de nascimento.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  GeopragSexoInput(
                    controller: _sexoController,
                    decoration: const InputDecoration(
                      labelText: 'Sexo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Informe o sexo.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cepController,
                    decoration: const InputDecoration(
                      labelText: 'CEP (opcional)',
                      hintText: '00000-000',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: salvando
                        ? null
                        : () {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }
                            context.read<CriarAdministradorCubit>().submit(
                              email: _emailController.text,
                              nome: _nomeController.text,
                              cpf: _cpfController.text,
                              dataNascimento: _dataNascimento!,
                              sexo: _sexoController.text,
                              cep: _cepController.text.isEmpty
                                  ? null
                                  : _cepController.text,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: salvando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Registrar Sub-Administrador'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Painel exibido no canto superior direito da tela de criação, mostrando a
/// senha inicial gerada automaticamente (GEOPRAG-61/68) para que quem
/// cadastrou possa lê-la e repassá-la verbalmente ao novo usuário. Some ao
/// clicar em "Concluir" — a senha não fica acessível em nenhuma outra tela.
class _SenhaGeradaBanner extends StatelessWidget {
  final String senha;
  final VoidCallback onConcluir;

  const _SenhaGeradaBanner({required this.senha, required this.onConcluir});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Senha inicial gerada',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Repasse verbalmente e pessoalmente ao novo usuário. Esta '
              'senha não será exibida novamente.',
            ),
            const SizedBox(height: 12),
            SelectableText(
              senha,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onConcluir,
                child: const Text('Concluir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
