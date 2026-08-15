import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/widgets/geoprag_cpf_input.dart';
import '../../../src/widgets/geoprag_data_nascimento_input.dart';
import '../../../src/widgets/geoprag_email_input.dart';
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
  DateTime? _dataNascimento;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _sexoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/administradores/novo',
      appBar: AppBar(title: const Text('Registrar Novo Administrador')),
      body: BlocConsumer<CriarAdministradorCubit, CriarAdministradorState>(
        listener: (context, state) {
          if (state is CriarAdministradorSucesso) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.conta.nome} cadastrado(a) como Sub-Administrador.',
                ),
              ),
            );
            // Esta tela é sempre alcançada por push a partir do dashboard
            // do módulo (`toCriarAdministrador`) — `.back()` volta pra lá,
            // onde o cadastro recém-criado já aparece na listagem.
            AdminNavigatorScope.of(context).back();
          } else if (state is CriarAdministradorErro) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final salvando = state is CriarAdministradorSalvando;
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
                        GeopragEmailInput(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'E-mail institucional',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GeopragCpfInput(
                          controller: _cpfController,
                          decoration: const InputDecoration(
                            labelText: 'CPF',
                            hintText: '000.000.000-00',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              (value == null || value.length != 14)
                              ? 'Informe um CPF válido.'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        GeopragDataNascimentoInput(
                          value: _dataNascimento,
                          onChanged: (data) =>
                              setState(() => _dataNascimento = data),
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
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: salvando
                              ? null
                              : () {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  context
                                      .read<CriarAdministradorCubit>()
                                      .submit(
                                        email: _emailController.text,
                                        nome: _nomeController.text,
                                        cpf: _cpfController.text,
                                        dataNascimento: _dataNascimento!,
                                        sexo: _sexoController.text,
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: salvando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
        },
      ),
    );
  }
}
