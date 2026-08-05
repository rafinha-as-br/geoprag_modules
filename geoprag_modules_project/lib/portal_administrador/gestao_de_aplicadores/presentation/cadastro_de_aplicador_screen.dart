import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/widgets/geoprag_senha_gerada_dialog.dart';
import '../../autenticacao/core/admin_navigator.dart';
import '../../widgets/admin_scaffold.dart';
import 'criar_aplicador_cubit.dart';
import 'criar_aplicador_state.dart';
import 'widgets/formulario_cadastro_aplicador.dart';

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
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();
  DateTime? _dataNascimento;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _sexoController.dispose();
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/aplicadores/novo',
      appBar: AppBar(title: const Text('Novo Aplicador')),
      body: BlocConsumer<CriarAplicadorCubit, CriarAplicadorState>(
        listener: (context, state) {
          if (state is CriarAplicadorSucesso) {
            GeopragSenhaGeradaDialog.mostrar(
              context,
              senha: state.senhaGerada,
              onConcluir: () {
                // GEOPRAG-65 (review Rafinha): esta tela é alcançada por
                // pushReplacement (destino de topo, não sub-rota), então
                // não há frame anterior para `.back()` — volta ao
                // dashboard explicitamente, onde o cadastro recém-criado
                // já aparece na listagem.
                AdminNavigatorScope.of(context).toAplicadores();
              },
            );
          } else if (state is CriarAplicadorErro) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final salvando = state is CriarAplicadorSalvando;
          return FormularioCadastroAplicador(
            formKey: _formKey,
            nomeController: _nomeController,
            emailController: _emailController,
            cpfController: _cpfController,
            sexoController: _sexoController,
            cepController: _cepController,
            ruaController: _ruaController,
            numeroController: _numeroController,
            complementoController: _complementoController,
            bairroController: _bairroController,
            cidadeController: _cidadeController,
            ufController: _ufController,
            dataNascimento: _dataNascimento,
            onDataNascimentoChanged: (data) =>
                setState(() => _dataNascimento = data),
            salvando: salvando,
            onSubmit: () => context.read<CriarAplicadorCubit>().submit(
              email: _emailController.text,
              nome: _nomeController.text,
              cpf: _cpfController.text,
              dataNascimento: _dataNascimento!,
              sexo: _sexoController.text,
              cep: _cepController.text,
              rua: _ruaController.text,
              numero: _numeroController.text,
              complemento: _complementoController.text.isEmpty
                  ? null
                  : _complementoController.text,
              bairro: _bairroController.text,
              cidade: _cidadeController.text,
              uf: _ufController.text,
            ),
          );
        },
      ),
    );
  }
}
