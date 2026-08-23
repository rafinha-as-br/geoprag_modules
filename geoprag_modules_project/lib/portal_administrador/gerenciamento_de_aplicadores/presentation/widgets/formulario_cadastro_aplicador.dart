import 'package:flutter/material.dart';

import '../../../../src/widgets/geoprag_cep_input.dart';
import '../../../../src/widgets/geoprag_cpf_input.dart';
import '../../../../src/widgets/geoprag_data_nascimento_input.dart';
import '../../../../src/widgets/geoprag_email_input.dart';
import '../../../../src/widgets/geoprag_sexo_input.dart';

/// Formulário de campos da tela de criação de Aplicador — extraído de
/// [CadastroDeAplicadorScreen] para um widget próprio (feedback de revisão
/// do PR #12, GEOPRAG-65).
///
/// Os controllers e o estado de `dataNascimento` continuam sendo
/// gerenciados pela tela (dono do ciclo de vida/`dispose`); este widget só
/// exibe o formulário e reporta a submissão via [onSubmit].
class FormularioCadastroAplicador extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nomeController;
  final TextEditingController emailController;
  final TextEditingController cpfController;
  final String? sexo;
  final ValueChanged<String?> onSexoChanged;
  final TextEditingController cepController;
  final TextEditingController ruaController;
  final TextEditingController numeroController;
  final TextEditingController complementoController;
  final TextEditingController bairroController;
  final TextEditingController cidadeController;
  final TextEditingController ufController;
  final DateTime? dataNascimento;
  final ValueChanged<DateTime?> onDataNascimentoChanged;
  final bool salvando;
  final VoidCallback onSubmit;

  const FormularioCadastroAplicador({
    super.key,
    required this.formKey,
    required this.nomeController,
    required this.emailController,
    required this.cpfController,
    required this.sexo,
    required this.onSexoChanged,
    required this.cepController,
    required this.ruaController,
    required this.numeroController,
    required this.complementoController,
    required this.bairroController,
    required this.cidadeController,
    required this.ufController,
    required this.dataNascimento,
    required this.onDataNascimentoChanged,
    required this.salvando,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
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
            // Formulário rola verticalmente (campos de endereço da
            // GEOPRAG-70 fazem o conteúdo passar da altura disponível em
            // telas menores).
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
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
                    controller: nomeController,
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
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Informe o e-mail.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  GeopragCpfInput(
                    controller: cpfController,
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
                    value: dataNascimento,
                    onChanged: onDataNascimentoChanged,
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento',
                      border: OutlineInputBorder(),
                    ),
                    validator: (_) => dataNascimento == null
                        ? 'Informe a data de nascimento.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  GeopragSexoInput(
                    value: sexo,
                    onChanged: onSexoChanged,
                    decoration: const InputDecoration(
                      labelText: 'Sexo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Informe o sexo.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  GeopragCepInput(
                    controller: cepController,
                    decoration: const InputDecoration(
                      labelText: 'CEP',
                      hintText: '00000-000',
                      border: OutlineInputBorder(),
                    ),
                    // CEP é obrigatório para o Aplicador (diferente do
                    // Administrador/Sub-Administrador) — alimenta o cadastro
                    // do ponto de aplicação atribuído a ele (ver "Regra de
                    // Negócio - Dados da Conta", seção 4.1).
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: ruaController,
                    decoration: const InputDecoration(
                      labelText: 'Rua',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Informe a rua.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: numeroController,
                          decoration: const InputDecoration(
                            labelText: 'Número',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Informe o número.'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: complementoController,
                          decoration: const InputDecoration(
                            labelText: 'Complemento (opcional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: bairroController,
                    decoration: const InputDecoration(
                      labelText: 'Bairro',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Informe o bairro.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: cidadeController,
                          decoration: const InputDecoration(
                            labelText: 'Cidade',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Informe a cidade.'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: ufController,
                          decoration: const InputDecoration(
                            labelText: 'UF',
                            border: OutlineInputBorder(),
                          ),
                          maxLength: 2,
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Informe a UF.'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: salvando
                        ? null
                        : () {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }
                            onSubmit();
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
      ),
    );
  }
}
