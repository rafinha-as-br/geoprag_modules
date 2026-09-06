import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/ponto_de_aplicacao_view_model.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/theme/geoprag_status.dart';

import '../gestao_de_aplicacoes_fixtures.dart';

void main() {
  group('apresentação dos estados', () {
    test('todo estado tem rótulo próprio, sem repetição', () {
      final rotulos = EstadoPontoDeAplicacao.values
          .map((estado) => estado.rotulo)
          .toList();

      expect(rotulos.toSet(), hasLength(EstadoPontoDeAplicacao.values.length));
      expect(rotulos, everyElement(isNotEmpty));
    });

    test('só o ponto em operação recebe a cor de "em dia"', () {
      final emDia = EstadoPontoDeAplicacao.values.where(
        (estado) => estado.status == GeopragStatus.emDia,
      );

      expect(emDia, [EstadoPontoDeAplicacao.ativa]);
    });

    test('fora de operação usa a cor de alerta', () {
      expect(
        EstadoPontoDeAplicacao.inativa.status,
        GeopragStatus.atrasado,
      );
      expect(
        EstadoPontoDeAplicacao.desativado.status,
        GeopragStatus.atrasado,
      );
    });
  });

  group('resumo', () {
    test('leva o nome do aplicador recebido e conta as execuções', () {
      final resumo = PontoDeAplicacaoResumoViewModel.fromEntity(
        pontoDeAplicacao(
          estado: EstadoPontoDeAplicacao.ativa,
          aplicadorId: '1',
          subpontos: [execucaoDeTeste],
          quantidadeDeSubpontos: 8,
        ),
        aplicadorNome: 'João Silva',
      );

      expect(resumo.aplicadorNome, 'João Silva');
      expect(resumo.execucoesRegistradas, 1);
      expect(resumo.quantidadeDeSubpontos, 8);
      expect(resumo.ativoSemRegistro, isFalse);
      expect(resumo.desativado, isFalse);
    });

    test('marca o ponto desativado para o filtro do dashboard', () {
      final resumo = PontoDeAplicacaoResumoViewModel.fromEntity(
        pontoDeAplicacao(estado: EstadoPontoDeAplicacao.desativado),
      );

      expect(resumo.desativado, isTrue);
    });
  });

  group('detalhe', () {
    test('carrega a vazão já calculada e preserva os parâmetros brutos', () {
      final detalhe = PontoDeAplicacaoDetalhadoViewModel.fromEntity(
        pontoDeAplicacao(
          larguraMetros: 2,
          profundidadeMetros: 0.5,
          velocidadeMetrosPorSegundo: 0.4,
        ),
      );

      expect(detalhe.larguraMetros, 2);
      expect(detalhe.profundidadeMetros, 0.5);
      expect(detalhe.velocidadeMetrosPorSegundo, 0.4);
      expect(detalhe.vazao, closeTo(0.4, 0.0001));
    });

    test('expõe as execuções registradas no ponto', () {
      final detalhe = PontoDeAplicacaoDetalhadoViewModel.fromEntity(
        pontoDeAplicacao(subpontos: [execucaoDeTeste]),
      );

      expect(detalhe.execucoes.single.realizadoEm, execucaoDeTeste.realizadoEm);
    });
  });
}
