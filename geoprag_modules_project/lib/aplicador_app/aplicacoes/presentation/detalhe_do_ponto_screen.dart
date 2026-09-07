import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/entities/ponto_de_aplicacao.dart' show Subponto;
import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_detail_screen.dart';
import '../../core/aplicador_navigator.dart';
import 'detalhe_do_ponto_cubit.dart';
import 'detalhe_do_ponto_state.dart';
import 'detalhe_do_ponto_view_model.dart';

/// Tela "Detalhe do Ponto Designado" (GEOPRAG-111) — dosagem em destaque,
/// instrução de campo usando a distância cadastrada do ponto (nunca mais
/// "150m" fixo, GEOPRAG-74) e histórico de aplicações já realizadas.
///
/// Assume que um [DetalheDoPontoDesignadoCubit] já foi provido acima na
/// árvore de widgets (ver
/// `AplicadorBootstrap.buildDetalheDoPontoDesignadoCubit` em
/// `bootstrap.dart`).
class DetalheDoPontoDesignadoScreen extends StatelessWidget {
  const DetalheDoPontoDesignadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do Ponto')),
      body: BlocBuilder<DetalheDoPontoDesignadoCubit, DetalheDoPontoDesignadoState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: BaseDetailScreen(
              variant: BaseDetailScreenVariant.duasColunas,
              title: switch (state) {
                DetalheDoPontoDesignadoLoaded(:final ponto) =>
                  '${ponto.nome} · ${ponto.identificador}',
                _ => '',
              },
              isLoading: state is DetalheDoPontoDesignadoLoading,
              errorMessage: switch (state) {
                DetalheDoPontoDesignadoError(:final message) =>
                  'Não foi possível carregar o ponto: $message',
                _ => null,
              },
              contentBuilder: (context) => switch (state) {
                DetalheDoPontoDesignadoLoaded(:final ponto) =>
                  _Conteudo(ponto: ponto),
                _ => const SizedBox.shrink(),
              },
            ),
          );
        },
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.ponto});

  final DetalheDoPontoDesignadoViewModel ponto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BadgePrimeiraOuRevisita(primeiraAplicacao: ponto.primeiraAplicacao),
        const SizedBox(height: 16),
        _DosagemDestaque(dosagemFormatada: ponto.dosagemFormatada),
        const SizedBox(height: 24),
        _InfoDoPonto(ponto: ponto),
        const SizedBox(height: 32),
        _BotaoIniciarAplicacao(ponto: ponto),
        const SizedBox(height: 32),
        _HistoricoDeAplicacoes(execucoes: ponto.execucoes),
      ],
    );
  }
}

class _BadgePrimeiraOuRevisita extends StatelessWidget {
  const _BadgePrimeiraOuRevisita({required this.primeiraAplicacao});

  final bool primeiraAplicacao;

  @override
  Widget build(BuildContext context) {
    final cor = primeiraAplicacao
        ? GeopragColors.blue600
        : GeopragColors.green900;
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(primeiraAplicacao ? 'Primeira aplicação' : 'Revisita'),
        backgroundColor: cor.withOpacity(0.12),
        labelStyle: TextStyle(color: cor, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DosagemDestaque extends StatelessWidget {
  const _DosagemDestaque({required this.dosagemFormatada});

  final String dosagemFormatada;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        decoration: BoxDecoration(
          color: GeopragColors.green900.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GeopragColors.green900, width: 2),
        ),
        child: Column(
          children: [
            const Text(
              'Dosagem Recomendada',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              dosagemFormatada,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: GeopragColors.green900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoDoPonto extends StatelessWidget {
  const _InfoDoPonto({required this.ponto});

  final DetalheDoPontoDesignadoViewModel ponto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${ponto.endereco}, ${ponto.numeroReferencia}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(ponto.descricaoDoTrecho, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.social_distance, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'Distância entre subpontos: '
              '${ponto.distanciaEntreSubpontosMetros.round()} m',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.timeline, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              '${ponto.execucoes.length} de ${ponto.quantidadeDeSubpontos} '
              'subpontos registrados',
            ),
          ],
        ),
      ],
    );
  }
}

class _BotaoIniciarAplicacao extends StatelessWidget {
  const _BotaoIniciarAplicacao({required this.ponto});

  final DetalheDoPontoDesignadoViewModel ponto;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        key: const Key('detalheDoPontoDesignadoScreen_iniciarAplicacao'),
        onPressed: ponto.podeIniciarAplicacao
            ? () =>
                  AplicadorNavigatorScope.of(context).toAplicacaoInfo(ponto.id)
            : null,
        icon: const Icon(Icons.water_drop),
        label: const Text('Iniciar Aplicação'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _HistoricoDeAplicacoes extends StatelessWidget {
  const _HistoricoDeAplicacoes({required this.execucoes});

  final List<Subponto> execucoes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Histórico de Aplicações',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (execucoes.isEmpty)
          const Text(
            'Nenhuma aplicação registrada ainda.',
            style: TextStyle(color: Colors.black54),
          )
        else
          ...execucoes.reversed.map(
            (subponto) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline, color: GeopragColors.green900),
              title: Text(_formatarData(subponto.realizadoEm)),
            ),
          ),
      ],
    );
  }

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }
}
