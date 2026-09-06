import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/state/acao_feedback.dart';
import '../../../src/theme/geoprag_colors.dart';
import '../../../src/widgets/base_detail_screen.dart';
import '../../../src/widgets/base_screen_feedback.dart';
import '../../../src/widgets/geoprag_status_badge.dart';
import '../../widgets/admin_scaffold.dart';
import 'ponto_de_aplicacao_detalhe_cubit.dart';
import 'ponto_de_aplicacao_detalhe_state.dart';
import 'ponto_de_aplicacao_view_model.dart';
import 'widgets/ativacao_dialog.dart';
import 'widgets/atribuir_aplicador_dialog.dart';
import 'widgets/desativar_dialog.dart';

/// Detalhe de um Ponto de Aplicação: parâmetros do trecho, direcionamento,
/// agendamento, execuções realizadas, auditoria e as ações individuais do
/// ciclo (GEOPRAG-110): ativar/agendar, atribuir/desatribuir aplicador,
/// desativar/reativar.
class VisualizacaoDePontoScreen extends StatelessWidget {
  const VisualizacaoDePontoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/aplicacoes',
      appBar: AppBar(title: const Text('Ponto de Aplicação')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child:
            BlocBuilder<
              PontoDeAplicacaoDetalheCubit,
              PontoDeAplicacaoDetalheState
            >(
              builder: (context, state) {
                return BaseDetailScreen(
                  variant: BaseDetailScreenVariant.duasColunas,
                  title: switch (state) {
                    PontoDeAplicacaoDetalheLoaded(:final ponto) =>
                      '${ponto.nome} · ${ponto.identificador}',
                    _ => '',
                  },
                  actions: switch (state) {
                    PontoDeAplicacaoDetalheLoaded(:final ponto, :final processando) =>
                      _acoesDoPonto(context, ponto, processando),
                    _ => const [],
                  },
                  isLoading: state is PontoDeAplicacaoDetalheLoading,
                  errorMessage: switch (state) {
                    PontoDeAplicacaoDetalheError(:final message) => message,
                    _ => null,
                  },
                  contentBuilder: (context) => switch (state) {
                    PontoDeAplicacaoDetalheLoaded(:final ponto, :final feedback) =>
                      _ConteudoDoPonto(ponto: ponto, feedback: feedback),
                    _ => const SizedBox.shrink(),
                  },
                );
              },
            ),
      ),
    );
  }
}

/// Monta os botões de ação visíveis para o estado atual do ponto — nunca
/// todos ao mesmo tempo, já que boa parte é mutuamente exclusiva (Ativar só
/// faz sentido fora de [EstadoPontoDeAplicacao.ativa]; Reativar só faz
/// sentido em [EstadoPontoDeAplicacao.desativado]).
List<Widget> _acoesDoPonto(
  BuildContext context,
  PontoDeAplicacaoDetalhadoViewModel ponto,
  bool processando,
) {
  final cubit = context.read<PontoDeAplicacaoDetalheCubit>();
  final botoes = <Widget>[];

  if (ponto.estado == EstadoPontoDeAplicacao.direcionada ||
      ponto.estado == EstadoPontoDeAplicacao.inativa) {
    botoes.add(
      OutlinedButton.icon(
        onPressed: processando
            ? null
            : () async {
                final agendamento = await showDialog<Agendamento>(
                  context: context,
                  builder: (_) => AtivacaoDialog(
                    nomeDoPonto: ponto.nome,
                    identificadorDoPonto: ponto.identificador,
                  ),
                );
                if (agendamento != null) await cubit.ativar(agendamento);
              },
        icon: const Icon(Icons.play_circle_outline),
        label: const Text('Ativar'),
      ),
    );
  }

  if (ponto.estado == EstadoPontoDeAplicacao.enderecada) {
    botoes.add(
      OutlinedButton.icon(
        onPressed: processando
            ? null
            : () async {
                final aplicadores = await cubit.listarAplicadoresParaAtribuir();
                if (!context.mounted) return;
                final aplicadorId = await showDialog<String>(
                  context: context,
                  builder: (_) =>
                      AtribuirAplicadorDialog(aplicadores: aplicadores),
                );
                if (aplicadorId != null) {
                  await cubit.atribuirAplicador(aplicadorId);
                }
              },
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Atribuir aplicador'),
      ),
    );
  }

  if (ponto.aplicadorId != null) {
    botoes.add(
      OutlinedButton.icon(
        onPressed: processando
            ? null
            : () async {
                final confirmado = await _confirmarAcaoSimples(
                  context,
                  titulo: 'Desatribuir aplicador',
                  mensagem:
                      'O ponto volta a ficar sem aplicador responsável. '
                      'Confirma?',
                  rotuloConfirmar: 'Desatribuir',
                );
                if (confirmado) await cubit.desatribuirAplicador();
              },
        icon: const Icon(Icons.person_remove_outlined),
        label: const Text('Desatribuir aplicador'),
      ),
    );
  }

  if (ponto.estado == EstadoPontoDeAplicacao.desativado) {
    botoes.add(
      OutlinedButton.icon(
        onPressed: processando
            ? null
            : () async {
                final confirmado = await _confirmarAcaoSimples(
                  context,
                  titulo: 'Reativar ponto',
                  mensagem:
                      'O ponto volta ao estado em que estava antes de ser '
                      'desativado. Confirma?',
                  rotuloConfirmar: 'Reativar',
                );
                if (confirmado) await cubit.reativar();
              },
        icon: const Icon(Icons.restore),
        label: const Text('Reativar'),
      ),
    );
  } else {
    botoes.add(
      OutlinedButton.icon(
        onPressed: processando
            ? null
            : () async {
                final confirmado = await showDesativarDialog(
                  context,
                  agendamento: ponto.agendamento,
                );
                if (confirmado) await cubit.desativar();
              },
        icon: const Icon(Icons.block),
        label: const Text('Desativar'),
      ),
    );
  }

  return botoes;
}

Future<bool> _confirmarAcaoSimples(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  required String rotuloConfirmar,
}) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(rotuloConfirmar),
        ),
      ],
    ),
  );
  return confirmado ?? false;
}

class _ConteudoDoPonto extends StatelessWidget {
  const _ConteudoDoPonto({required this.ponto, this.feedback});

  final PontoDeAplicacaoDetalhadoViewModel ponto;
  final AcaoFeedback? feedback;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GeopragStatusBadge(
            status: ponto.estado.status,
            label: ponto.estado.rotulo,
          ),
        ),
        if (feedback != null) ...[
          const SizedBox(height: 16),
          BaseScreenFeedback(feedback: feedback!),
        ],
        const SizedBox(height: 24),
        _SecaoDeLocalizacao(ponto: ponto),
        _SecaoDeParametros(ponto: ponto),
        _Secao(
          titulo: 'Direcionamento',
          child: _Linha(
            rotulo: 'Aplicador responsável',
            valor: ponto.aplicadorNome ?? 'Nenhum aplicador direcionado',
          ),
        ),
        _Secao(titulo: 'Agendamento', child: _ConteudoDoAgendamento(ponto: ponto)),
        _Secao(
          titulo: 'Execuções realizadas',
          child: ponto.execucoes.isEmpty
              ? const Text(
                  'Nenhuma aplicação registrada neste ponto.',
                  style: TextStyle(color: Colors.black54),
                )
              : Column(
                  children: [
                    for (final execucao in ponto.execucoes)
                      _LinhaDeExecucao(execucao: execucao),
                  ],
                ),
        ),
        const _SlotDeRegistroManual(),
        const SizedBox(height: 16),
        const ExpansionTile(
          title: Text('Auditoria'),
          childrenPadding: EdgeInsets.only(bottom: 16),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nenhum evento de auditoria registrado.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SecaoDeLocalizacao extends StatelessWidget {
  const _SecaoDeLocalizacao({required this.ponto});

  final PontoDeAplicacaoDetalhadoViewModel ponto;

  @override
  Widget build(BuildContext context) {
    return _Secao(
      titulo: 'Localização',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Linha(rotulo: 'Bairro', valor: ponto.bairro),
          _Linha(rotulo: 'Endereço', valor: ponto.endereco),
          _Linha(rotulo: 'Número / referência', valor: ponto.numeroReferencia),
          _Linha(rotulo: 'Trecho', valor: ponto.descricaoDoTrecho),
        ],
      ),
    );
  }
}

class _SecaoDeParametros extends StatelessWidget {
  const _SecaoDeParametros({required this.ponto});

  final PontoDeAplicacaoDetalhadoViewModel ponto;

  @override
  Widget build(BuildContext context) {
    return _Secao(
      titulo: 'Parâmetros do trecho',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Linha(rotulo: 'Largura', valor: '${_numero(ponto.larguraMetros)} m'),
          _Linha(
            rotulo: 'Profundidade',
            valor: '${_numero(ponto.profundidadeMetros)} m',
          ),
          _Linha(
            rotulo: 'Velocidade',
            valor: '${_numero(ponto.velocidadeMetrosPorSegundo)} m/s',
          ),
          const SizedBox(height: 12),
          _CardDeVazao(vazao: ponto.vazao),
          const SizedBox(height: 12),
          _Linha(
            rotulo: 'Dosagem por aplicação',
            valor: '${_numero(ponto.dosagemMl)} ml',
          ),
          _Linha(
            rotulo: 'Distância entre subpontos',
            valor: '${_numero(ponto.distanciaEntreSubpontosMetros)} m',
          ),
          _Linha(
            rotulo: 'Subpontos por ciclo',
            valor: '${ponto.quantidadeDeSubpontos}',
          ),
        ],
      ),
    );
  }
}

class _ConteudoDoAgendamento extends StatelessWidget {
  const _ConteudoDoAgendamento({required this.ponto});

  final PontoDeAplicacaoDetalhadoViewModel ponto;

  @override
  Widget build(BuildContext context) {
    final agendamento = ponto.agendamento;
    if (agendamento == null) {
      return const Text(
        'Nenhum agendamento definido.',
        style: TextStyle(color: Colors.black54),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Linha(
          rotulo: 'Intervalo',
          valor: '${agendamento.intervaloDias} dia(s)',
        ),
        const SizedBox(height: 8),
        for (final data in agendamento.datas)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  switch (data.status) {
                    StatusDataAgendada.concluida => Icons.check_circle,
                    StatusDataAgendada.cancelada => Icons.cancel_outlined,
                    StatusDataAgendada.pendente => Icons.schedule,
                  },
                  size: 18,
                  color: switch (data.status) {
                    StatusDataAgendada.concluida => GeopragColors.statusEmDia,
                    StatusDataAgendada.cancelada => Colors.black38,
                    StatusDataAgendada.pendente => Colors.black54,
                  },
                ),
                const SizedBox(width: 8),
                Text(_dataHora(data.data)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Vazão em destaque: é o único número desta tela que ninguém digitou.
class _CardDeVazao extends StatelessWidget {
  const _CardDeVazao({required this.vazao});

  final double vazao;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GeopragColors.blue600.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GeopragColors.blue600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vazão (calculada automaticamente)',
            style: TextStyle(
              color: GeopragColors.blue600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_numero(vazao)} m³/s',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Largura × profundidade × velocidade.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Espaço reservado para o registro manual de aplicação pelo portal —
/// funcionalidade de épico próprio, ainda não detalhada.
class _SlotDeRegistroManual extends StatelessWidget {
  const _SlotDeRegistroManual();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: const Column(
        children: [
          Icon(Icons.edit_note, color: Colors.black38),
          SizedBox(height: 8),
          Text(
            'Registro manual de aplicação pelo portal',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          Text(
            'Ainda não disponível.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, required this.child});

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        child,
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220,
            child: Text(rotulo, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaDeExecucao extends StatelessWidget {
  const _LinhaDeExecucao({required this.execucao});

  final Subponto execucao;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.place_outlined),
      title: Text('Aplicada em ${_dataHora(execucao.realizadoEm)}'),
      subtitle: Text(
        'Registrada em ${_dataHora(execucao.registradoEm)} · '
        '${execucao.latitude.toStringAsFixed(4)}, '
        '${execucao.longitude.toStringAsFixed(4)}',
      ),
    );
  }
}

/// Formata sem casas decimais quando o valor é inteiro (2 m, não 2.0 m).
String _numero(double valor) =>
    valor == valor.roundToDouble() ? '${valor.round()}' : valor.toString();

String _dataHora(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  final hora = data.hour.toString().padLeft(2, '0');
  final minuto = data.minute.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year} às $hora:$minuto';
}
