import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../autenticacao/core/admin_navigator.dart';
import 'criar_administrador_cubit.dart';
import 'criar_administrador_state.dart';

/// Formata uma data como `dd/MM/yyyy` (sem dependência de `intl`, seguindo o
/// padrão já usado neste pacote para formatação manual).
String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

/// Formulário de criação de novo administrador (GEOPRAG-36). Acesso restrito
/// a quem tem cargo Administrador — o guard é aplicado no `redirect` do
/// GoRouter (`app_administrador/lib/main.dart`), não nesta tela.
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

  Future<void> _selecionarDataNascimento() async {
    final agora = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(agora.year - 18),
      firstDate: DateTime(1900),
      lastDate: agora,
    );
    if (data != null) {
      setState(() => _dataNascimento = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Rota atual foi alcançada por pushReplacement a partir da
            // sidebar (mesmo padrão dos demais itens de topo) — não há uma
            // tela anterior confiável para `.back()`, por isso volta
            // explicitamente ao dashboard.
            AdminNavigatorScope.of(context).toDashboard();
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
                        TextFormField(
                          controller: _cpfController,
                          decoration: const InputDecoration(
                            labelText: 'CPF',
                            hintText: '000.000.000-00',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _CpfInputFormatter(),
                          ],
                          validator: (value) =>
                              (value == null || value.length != 14)
                              ? 'Informe um CPF válido.'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        FormField<DateTime>(
                          initialValue: _dataNascimento,
                          validator: (_) => _dataNascimento == null
                              ? 'Informe a data de nascimento.'
                              : null,
                          builder: (field) => InkWell(
                            onTap: () async {
                              await _selecionarDataNascimento();
                              field.didChange(_dataNascimento);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Data de nascimento',
                                border: const OutlineInputBorder(),
                                errorText: field.errorText,
                              ),
                              child: Text(
                                _dataNascimento == null
                                    ? 'Selecione a data'
                                    : _formatarData(_dataNascimento!),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
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
                                  context.read<CriarAdministradorCubit>().submit(
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

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.substring(
      0,
      newValue.text.length.clamp(0, 11),
    );
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('-');
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
