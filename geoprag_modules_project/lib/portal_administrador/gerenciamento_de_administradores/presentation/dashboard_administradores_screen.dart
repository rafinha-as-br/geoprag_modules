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
import 'solicitacoes_promocao_cubit.dart';
import 'solicitacoes_promocao_state.dart';

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
                      _BotaoSolicitacoesPromocao(),
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
    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[100]),
          children: const [
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Nome',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'E-mail',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Cargo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        for (final administrador in administradores)
          _buildTableRow(context, administrador, contaAtual),
      ],
    );
  }

  TableRow _buildTableRow(
    BuildContext context,
    AdministradorViewModel administrador,
    AdminAccount? contaAtual,
  ) {
    void abrirDetalhes() {
      showAdministradorDetalheDialog(
        context,
        administrador: administrador,
        contaAtual: contaAtual,
      );
    }

    Widget celula(Widget child) => TableRowInkWell(
      onTap: abrirDetalhes,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );

    return TableRow(
      children: [
        celula(Text(administrador.nome)),
        celula(Text(administrador.email)),
        celula(Text(administrador.cargoLabel)),
        celula(
          GeopragStatusBadge(
            status: administrador.ativo
                ? GeopragStatus.emDia
                : GeopragStatus.atrasado,
            label: administrador.ativo ? 'Ativo' : 'Desativado',
            dense: true,
          ),
        ),
      ],
    );
  }
}

/// Botão que leva à tela de Solicitações de Promoção, com indicador de
/// quantas solicitações em aberto ainda aguardam o voto do usuário atual
/// (RN "Promoção e Rebaixamento de Cargo de Administrador", seção 4, regra
/// 6).
class _BotaoSolicitacoesPromocao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SolicitacoesPromocaoCubit, SolicitacoesPromocaoState>(
      builder: (context, state) {
        final pendentes = state is SolicitacoesPromocaoLoaded
            ? state.solicitacoes
                  .where((s) => !s.jaVotei && !s.souOSolicitante)
                  .length
            : 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                AdminNavigatorScope.of(
                  context,
                ).toSolicitacoesPromocaoAdministrador();
              },
              icon: const Icon(Icons.how_to_vote),
              label: const Text('Solicitações de Promoção'),
            ),
            if (pendentes > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '$pendentes',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
