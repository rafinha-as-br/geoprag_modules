import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/widgets/geoprag_cpf_input.dart';
import '../../../src/widgets/geoprag_data_nascimento_input.dart';
import '../../../src/widgets/geoprag_sexo_input.dart';
import '../../autenticacao/core/admin_navigator.dart';
import '../../widgets/admin_scaffold.dart';
import 'criar_aplicador_cubit.dart';
import 'criar_aplicador_state.dart';

/// Formulário de criação de novo Aplicador (GEOPRAG-65). Segue o mesmo
/// padrão de tela, campos e validações já usado na criação de Administrador
/// (`criacao_de_administrador_screen.dart`, GEOPRAG-36) — ver
/// [Módulo Gerenciamento de Aplicadores - Cadastro](https://rafinha84dev.atlassian.net/wiki/spaces/Geoprag/pages/38043682)
/// para a especificação completa.
///
/// Diferente do Administrador, o CEP é obrigatório aqui (alimenta o cadastro
/// do ponto de aplicação atribuído ao Aplicador) e não há campo de senha —
/// a senha inicial é gerada automaticamente (ver [CriarAplicadorCubit]).
class CadastroDeAplicadorScreen extends StatefulWidget {
  const CadastroDeAplicadorScreen({super.key});

  @override
  State<CadastroDeAplicadorScreen> createState() =>
      _CadastroDeAplicadorScreenState();
}

class _CadastroDeAplicadorScreenState extends State<CadastroDeAplicadorScreen> {
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
  /// o cadastro ser salvo (GEOPRAG-61/65) — não é reexibida depois que a
  /// tela é fechada, nem persistida em nenhum outro lugar.
  String? _senhaGerada;

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/aplicadores/novo',
      appBar: AppBar(title: const Text('Novo Aplicador')),
      body: BlocConsumer<CriarAplicadorCubit, CriarAplicadorState>(
        listener: (context, state) {
          if (state is CriarAplicadorSucesso) {
            // Não navega de volta imediatamente — a senha gerada precisa
            // ficar visível na tela até o Administrador/Sub-Administrador
            // confirmar que já repassou ela verbalmente ao voluntário (ver
            // botão "Concluir" em [_SenhaGeradaBanner]).
            setState(() => _senhaGerada = state.senhaGerada);
          } else if (state is CriarAplicadorErro) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final salvando = state is CriarAplicadorSalvando;
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
                      // Dashboard de Aplicadores (`toCriarAplicador`) —
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
                    'A senha inicial é gerada automaticamente e exibida ao '
                    'salvar — repasse-a verbalmente e pessoalmente ao '
                    'voluntário.',
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
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Informe o e-mail.'
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
                      labelText: 'CEP',
                      hintText: '00000-000',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    // CEP é obrigatório para o Aplicador (diferente do
                    // Administrador/Sub-Administrador) — alimenta o cadastro
                    // do ponto de aplicação atribuído a ele (ver "Regra de
                    // Negócio - Dados da Conta", seção 4.1).
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Informe o CEP.'
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
                            context.read<CriarAplicadorCubit>().submit(
                              email: _emailController.text,
                              nome: _nomeController.text,
                              cpf: _cpfController.text,
                              dataNascimento: _dataNascimento!,
                              sexo: _sexoController.text,
                              cep: _cepController.text,
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
                        : const Text('Registrar Aplicador'),
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

/// Painel exibido no canto superior direito da tela de cadastro, mostrando a
/// senha inicial gerada automaticamente (GEOPRAG-61/65) para que quem
/// cadastrou possa lê-la e repassá-la verbalmente ao voluntário. Some ao
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
              'Repasse verbalmente e pessoalmente ao voluntário. Esta '
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
