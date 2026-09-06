import 'package:flutter/material.dart';

import '../../../src/widgets/base_list_screen.dart';
import '../../widgets/admin_scaffold.dart';
import 'ponto_de_aplicacao_view_model.dart';
import 'pontos_de_aplicacao_cubit.dart';

/// Panorama de todos os Pontos de Aplicação do município: alertas, cobertura
/// por bairro e a listagem filtrável. Ver [PontosDeAplicacaoCubit].
class DashboardDeAplicacoesScreen extends StatelessWidget {
  const DashboardDeAplicacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/aplicacoes',
      appBar: AppBar(title: const Text('Gestão de Aplicações')),
      body: const SingleChildScrollView(
        child:
            BaseListScreen<
              PontosDeAplicacaoCubit,
              PontoDeAplicacaoResumoViewModel
            >(),
      ),
    );
  }
}
