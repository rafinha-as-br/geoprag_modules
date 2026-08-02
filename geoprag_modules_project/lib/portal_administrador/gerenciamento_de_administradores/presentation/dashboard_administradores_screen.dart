import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../widgets/admin_scaffold.dart';
import '../../autenticacao/core/admin_account.dart';
import '../../autenticacao/core/admin_navigator.dart';
import '../../autenticacao/presentation/admin_session_cubit.dart';
import '../../autenticacao/presentation/admin_session_state.dart';
import 'administrador_detalhe_dialog.dart';
import 'administrador_view_model.dart';
import 'administradores_cubit.dart';
import 'administradores_state.dart';
import 'widgets/botao_solicitacoes_promocao.dart';
import 'widgets/geoprag_data_table.dart';

/// Dashboard do módulo Gerenciamento de Administradores (GEOPRAG-36):
/// listagem com busca, desativação de cadastro e solicitação de promoção
/// de Sub-Administrador — pendências apontadas na review reprovada da
/// issue.
class DashboardAdministradoresScreen extends StatefulWidget {
  const DashboardAdministradoresScreen({super.key});

  @override
  State<DashboardAdministradoresScreen> createState() =>
      _DashboardAdministradoresScreenState();
}

class _DashboardAdministradoresScreenState
    extends State<DashboardAdministradoresScreen> {
  final _buscaController = TextEditingController();
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(() {
      setState(() => _busca = _buscaController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  List<AdministradorViewModel> _filtrar(List<AdministradorViewModel> lista) {
    if (_busca.isEmpty) return lista;
    return lista
        .where(
          (a) =>
              a.nome.toLowerCase().contains(_busca) ||
              a.email.toLowerCase().contains(_busca) ||
              a.cargoLabel.toLowerCase().contains(_busca),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<AdminSessionCubit>().state;
    final contaAtual = sessionState is AdminSessionAutenticado
        ? sessionState.conta
        : null;

    return AdminScaffold(
      currentRoute: '/administradores',
      appBar: AppBar(title: const Text('Gerenciamento de Administradores')),
      body: BlocListener<AdministradoresCubit, AdministradoresState>(
        listener: (context, state) {
          if (state is AdministradoresLoaded && state.avisoAcao != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.avisoAcao!)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  const Text(
                    'Administradores Cadastrados',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const BotaoSolicitacoesPromocao(),
                      ElevatedButton.icon(
                        onPressed: () {
                          AdminNavigatorScope.of(
                            context,
                          ).toCriarAdministrador();
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Novo Administrador'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _buscaController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nome, e-mail ou cargo...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<AdministradoresCubit, AdministradoresState>(
                        builder: (context, state) {
                          return switch (state) {
                            AdministradoresLoading() => const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            AdministradoresError(:final message) => Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Não foi possível carregar os administradores: $message',
                              ),
                            ),
                            AdministradoresLoaded(:final administradores) =>
                              _buildTabela(
                                context,
                                _filtrar(administradores),
                                contaAtual,
                              ),
                          };
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabela(
    BuildContext context,
    List<AdministradorViewModel> administradores,
    AdminAccount? contaAtual,
  ) {
    return GeopragDataTable<AdministradorViewModel>(
      items: administradores,
      onRowTap: (administrador) => showAdministradorDetalheDialog(
        context,
        administrador: administrador,
        contaAtual: contaAtual,
      ),
      columns: [
        GeopragDataColumn(
          label: 'Nome',
          width: const FlexColumnWidth(2),
          cellBuilder: (context, a) => Text(a.nome),
        ),
        GeopragDataColumn(
          label: 'E-mail',
          width: const FlexColumnWidth(2),
          cellBuilder: (context, a) => Text(a.email),
        ),
        GeopragDataColumn(
          label: 'Cargo',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, a) => Text(a.cargoLabel),
        ),
        GeopragDataColumn(
          label: 'Status',
          width: const FlexColumnWidth(1),
          cellBuilder: (context, a) => GeopragStatusBadge(
            status: a.ativo ? GeopragStatus.emDia : GeopragStatus.atrasado,
            label: a.ativo ? 'Ativo' : 'Desativado',
            dense: true,
          ),
        ),
      ],
    );
  }
}
