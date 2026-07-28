import 'package:flutter/material.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../core/aplicador_navigator.dart';
import '../core/denuncia_de_foco.dart';
import 'denuncia_de_foco_view_model.dart';

class CadastroDoFocoScreen extends StatefulWidget {
  const CadastroDoFocoScreen({super.key});

  @override
  State<CadastroDoFocoScreen> createState() => _CadastroDoFocoScreenState();
}

class _CadastroDoFocoScreenState extends State<CadastroDoFocoScreen> {
  final _formKey = GlobalKey<FormState>();
  NivelInfestacaoFoco _nivelInfestacao = NivelInfestacaoFoco.medio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Denúncia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GeopragColors.neutralLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GeopragColors.green500.withOpacity(0.5),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.gps_fixed, color: GeopragColors.green900),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Localização atual capturada automaticamente para a vistoria.',
                        style: TextStyle(color: GeopragColors.green900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nível de Infestação',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<NivelInfestacaoFoco>(
                value: _nivelInfestacao,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: NivelInfestacaoFoco.values.map((nivel) {
                  return DropdownMenuItem<NivelInfestacaoFoco>(
                    value: nivel,
                    child: Text(DenunciaDeFocoViewModel.labelDoNivel(nivel)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _nivelInfestacao = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Descrição do local (Ex: perto da ponte)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Observações extras (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO(GEOPRAG-24): chamar
                  // DenunciaDeFocoRepository.registrar com os dados do
                  // formulário assim que o envio deixar de ser decorativo.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Denúncia enviada com sucesso!'),
                      backgroundColor: GeopragColors.green900,
                    ),
                  );
                  AplicadorNavigatorScope.of(context).toDenuncias();
                },
                icon: const Icon(Icons.send),
                label: const Text('Enviar Denúncia'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  AplicadorNavigatorScope.of(context).back();
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
