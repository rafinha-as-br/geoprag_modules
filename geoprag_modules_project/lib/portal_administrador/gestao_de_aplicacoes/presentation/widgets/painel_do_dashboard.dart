import 'package:flutter/material.dart';

import '../../../../src/entities/ponto_de_aplicacao.dart';
import '../../../../src/theme/geoprag_colors.dart';
import '../../../../src/theme/geoprag_status.dart';
import '../../../../src/widgets/geoprag_filter_dropdown.dart';
import '../../../../src/widgets/geoprag_map_placeholder.dart';
import '../../../../src/widgets/geoprag_search_field.dart';
import '../../../autenticacao/core/admin_navigator.dart';
import '../ponto_de_aplicacao_view_model.dart';

/// Rótulo da opção "sem filtro de estado" no dropdown.
const _todosOsEstados = 'Todos os estados';

/// Tudo que o dashboard de Gestão de Aplicações mostra acima da tabela:
/// alertas, mapa de cobertura por bairro e os controles de filtragem.
///
/// Vai no slot `filter` de `BaseListScreenModel` porque é exatamente onde
/// esse conteúdo aparece: dentro do card, acima da tabela. O template não tem
/// um segundo slot, e pôr o painel fora dele o jogaria acima do título da
/// tela, separado da listagem que ele resume.
class PainelDoDashboard extends StatelessWidget {
  final List<PontoDeAplicacaoResumoViewModel> alertas;
  final List<CoberturaDeBairroViewModel> cobertura;
  final bool incluirDesativados;
  final EstadoPontoDeAplicacao? estadoSelecionado;
  final ValueChanged<String> onBuscar;
  final ValueChanged<EstadoPontoDeAplicacao?> onFiltrarPorEstado;
  final ValueChanged<bool> onAlternarIncluirDesativados;

  const PainelDoDashboard({
    super.key,
    required this.alertas,
    required this.cobertura,
    required this.incluirDesativados,
    required this.estadoSelecionado,
    required this.onBuscar,
    required this.onFiltrarPorEstado,
    required this.onAlternarIncluirDesativados,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (alertas.isNotEmpty) ...[
          _BlocoDeAlertas(alertas: alertas),
          const SizedBox(height: 16),
        ],
        _MapaDeCobertura(cobertura: cobertura),
        const SizedBox(height: 16),
        GeopragSearchField(
          hintText: 'Buscar por nome, identificador ou bairro...',
          onChanged: onBuscar,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GeopragFilterDropdown(
                label: 'Estado',
                options: [
                  _todosOsEstados,
                  for (final estado in EstadoPontoDeAplicacao.values)
                    estado.rotulo,
                ],
                initialValue: estadoSelecionado?.rotulo ?? _todosOsEstados,
                onChanged: (rotulo) => onFiltrarPorEstado(
                  rotulo == _todosOsEstados
                      ? null
                      : EstadoPontoDeAplicacao.values.firstWhere(
                          (estado) => estado.rotulo == rotulo,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CheckboxListTile(
                value: incluirDesativados,
                onChanged: (valor) =>
                    onAlternarIncluirDesativados(valor ?? false),
                title: const Text('Incluir desativados'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Pontos em operação que ainda não receberam nenhuma aplicação.
class _BlocoDeAlertas extends StatelessWidget {
  const _BlocoDeAlertas({required this.alertas});

  final List<PontoDeAplicacaoResumoViewModel> alertas;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GeopragStatus.atrasado.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GeopragColors.statusAtrasado),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: GeopragColors.statusAtrasado,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${alertas.length} ponto(s) ativo(s) sem nenhuma aplicação '
                  'registrada',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: GeopragColors.statusAtrasado,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final ponto in alertas)
            Text('• ${ponto.nome} (${ponto.bairro}) — ${ponto.identificador}'),
        ],
      ),
    );
  }
}

/// Mapa mock: mostra a cobertura de cada bairro, não a posição real dos
/// pontos.
///
/// Um ponto só ganha coordenada na primeira aplicação feita em campo, então
/// não há lat/lng para posicionar no cadastro. Os cartões abaixo do
/// placeholder são a informação de verdade desta versão.
class _MapaDeCobertura extends StatelessWidget {
  const _MapaDeCobertura({required this.cobertura});

  final List<CoberturaDeBairroViewModel> cobertura;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GeopragMapPlaceholder(
          message: 'Mapa de cobertura por bairro',
          height: 140,
          icon: Icons.map,
          backgroundColor: GeopragColors.neutralLight,
          borderColor: GeopragColors.green500,
          textColor: GeopragColors.green900,
        ),
        const SizedBox(height: 12),
        if (cobertura.isEmpty)
          const Text('Nenhum bairro com ponto de aplicação cadastrado.')
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final bairro in cobertura)
                _CartaoDeBairro(cobertura: bairro),
            ],
          ),
      ],
    );
  }
}

/// Cartão de um bairro na legenda do mapa — e a única entrada para a tela do
/// bairro nesta versão, já que os pinos do placeholder só ficam clicáveis na
/// issue seguinte.
class _CartaoDeBairro extends StatelessWidget {
  const _CartaoDeBairro({required this.cobertura});

  final CoberturaDeBairroViewModel cobertura;

  @override
  Widget build(BuildContext context) {
    final status = cobertura.status;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () =>
          AdminNavigatorScope.of(context).toAplicacaoBairro(cobertura.bairro),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: status.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: status.color),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              cobertura.bairro,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: status.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${cobertura.totalDePontos} ponto(s) · ${cobertura.pontosAtivos} ativo(s)',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
