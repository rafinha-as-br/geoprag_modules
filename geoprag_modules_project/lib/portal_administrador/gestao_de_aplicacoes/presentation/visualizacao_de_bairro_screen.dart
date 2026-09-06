import 'package:flutter/material.dart';

import '../../../src/widgets/base_list_screen.dart';
import '../../widgets/admin_scaffold.dart';
import 'ponto_de_aplicacao_view_model.dart';
import 'pontos_do_bairro_cubit.dart';

/// Pontos de Aplicação de um bairro. Ver [PontosDoBairroCubit].
class VisualizacaoDeBairroScreen extends StatelessWidget {
  const VisualizacaoDeBairroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/aplicacoes',
      appBar: AppBar(title: const Text('Pontos de Aplicação do Bairro')),
      body: const SingleChildScrollView(
        child:
            BaseListScreen<PontosDoBairroCubit, PontoDeAplicacaoResumoViewModel>(),
      ),
    );
  }
}
