import 'package:flutter/material.dart';

import '../../../src/widgets/base_list_screen.dart';
import '../../../src/widgets/geoprag_back_button.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'ponto_de_aplicacao_view_model.dart';
import 'pontos_do_bairro_cubit.dart';

/// Pontos de Aplicação de um bairro. Ver [PontosDoBairroCubit].
class VisualizacaoDeBairroScreen extends StatelessWidget {
  const VisualizacaoDeBairroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pontos de Aplicação do Bairro'),
        // GEOPRAG-151: alcançada pela legenda do dashboard de Aplicações —
        // um único nível acima.
        leading: GeopragBackButton(
          onBack: () => AdminNavigatorScope.of(context).toAplicacoes(),
        ),
      ),
      body: const SingleChildScrollView(
        child:
            BaseListScreen<
              PontosDoBairroCubit,
              PontoDeAplicacaoResumoViewModel
            >(),
      ),
    );
  }
}
