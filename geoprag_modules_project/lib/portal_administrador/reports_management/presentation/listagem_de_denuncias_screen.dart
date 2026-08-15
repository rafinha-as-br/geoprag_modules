import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/theme/geoprag_colors.dart';
import '../../../src/theme/geoprag_status.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../widgets/admin_scaffold.dart';
import '../../autenticacao/core/admin_navigator.dart';
import 'denuncia_view_model.dart';
import 'denuncias_cubit.dart';
import 'denuncias_state.dart';

const _todosOsStatus = 'Todas';
const _todosOsNiveis = 'Todos';

const _opcoesStatus = [
  _todosOsStatus,
  'Recebida',
  'Equipe a Investigar',
  'Em Combate',
  'Resolvido',
];

const _opcoesNivel = [_todosOsNiveis, 'Alto', 'Médio', 'Baixo'];

/// Listagem completa e pesquisável de todas as Denúncias registradas
/// (histórico completo, com filtro por status/nível e busca textual),
/// diferente do panorama de triagem em `DashboardDenunciasAdminScreen`.
class ListagemDeDenunciasScreen extends StatefulWidget {
  const ListagemDeDenunciasScreen({super.key});

  @override
  State<ListagemDeDenunciasScreen> createState() =>
      _ListagemDeDenunciasScreenState();
}

class _ListagemDeDenunciasScreenState extends State<ListagemDeDenunciasScreen> {
  String _statusFiltro = _todosOsStatus;
  String _nivelFiltro = _todosOsNiveis;
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/denuncias_admin',
      appBar: AppBar(title: const Text('Listagem de Denúncias')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Todas as Denúncias Registradas',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText:
                                  'Buscar por denunciante ou descrição...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (valor) {
                              setState(() => _busca = valor);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _statusFiltro,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              for (final status in _opcoesStatus)
                                DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                            ],
                            onChanged: (valor) {
                              if (valor != null) {
                                setState(() => _statusFiltro = valor);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _nivelFiltro,
                            decoration: const InputDecoration(
                              labelText: 'Nível de Infestação',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              for (final nivel in _opcoesNivel)
                                DropdownMenuItem(
                                  value: nivel,
                                  child: Text(nivel),
                                ),
                            ],
                            onChanged: (valor) {
                              if (valor != null) {
                                setState(() => _nivelFiltro = valor);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<DenunciasCubit, DenunciasState>(
                      builder: (context, state) {
                        return switch (state) {
                          DenunciasLoading() => const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          DenunciasError(:final message) => Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Não foi possível carregar as denúncias: $message',
                            ),
                          ),
                          DenunciasLoaded(:final denuncias) => _buildTabela(
                            context,
                            _filtrar(denuncias),
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
    );
  }

  List<DenunciaResumoViewModel> _filtrar(
    List<DenunciaResumoViewModel> denuncias,
  ) {
    final busca = _busca.trim().toLowerCase();
    return denuncias.where((denuncia) {
      final statusCombina =
          _statusFiltro == _todosOsStatus || denuncia.status == _statusFiltro;
      final nivelCombina =
          _nivelFiltro == _todosOsNiveis ||
          denuncia.nivelInfestacao == _nivelFiltro;
      final buscaCombina =
          busca.isEmpty ||
          denuncia.denunciante.toLowerCase().contains(busca) ||
          denuncia.descricao.toLowerCase().contains(busca);
      return statusCombina && nivelCombina && buscaCombina;
    }).toList();
  }

  Widget _buildTabela(
    BuildContext context,
    List<DenunciaResumoViewModel> denuncias,
  ) {
    if (denuncias.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Nenhuma denúncia encontrada para os filtros aplicados.'),
      );
    }
    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[100]),
          children: const [
            _CabecalhoCelula('Data'),
            _CabecalhoCelula('Denunciante'),
            _CabecalhoCelula('Descrição do Local'),
            _CabecalhoCelula('Nível'),
            _CabecalhoCelula('Status'),
            _CabecalhoCelula('Ações'),
          ],
        ),
        for (final denuncia in denuncias) _buildLinha(context, denuncia),
      ],
    );
  }

  TableRow _buildLinha(BuildContext context, DenunciaResumoViewModel denuncia) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(denuncia.dataFormatada),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(denuncia.denunciante),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(denuncia.descricao),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            denuncia.nivelInfestacao,
            style: TextStyle(
              color: _corNivel(denuncia.nivelInfestacao),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: GeopragStatusBadge(
            status: _statusParaBadge(denuncia.status),
            label: denuncia.status,
            dense: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            icon: const Icon(Icons.visibility, color: Colors.blue),
            onPressed: () {
              AdminNavigatorScope.of(
                context,
              ).toDenunciaAdminDetalhes(denuncia.id);
            },
            tooltip: 'Analisar e Tratar',
          ),
        ),
      ],
    );
  }
}

Color _corNivel(String nivel) {
  switch (nivel) {
    case 'Alto':
      return GeopragColors.statusAtrasado;
    case 'Médio':
      return GeopragColors.statusDenuncia;
    default:
      return GeopragColors.statusEmDia;
  }
}

GeopragStatus _statusParaBadge(String status) =>
    status == 'Resolvido' ? GeopragStatus.emDia : GeopragStatus.denuncia;

class _CabecalhoCelula extends StatelessWidget {
  const _CabecalhoCelula(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
