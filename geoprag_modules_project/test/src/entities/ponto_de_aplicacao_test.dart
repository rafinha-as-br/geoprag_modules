import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

PontoDeAplicacao pontoDeTeste({
  EstadoPontoDeAplicacao estado = EstadoPontoDeAplicacao.enderecada,
  String? aplicadorId,
  List<Subponto> subpontos = const [],
  double larguraMetros = 2,
  double profundidadeMetros = 0.5,
  double velocidadeMetrosPorSegundo = 0.4,
}) {
  return PontoDeAplicacao(
    id: 'pa1',
    identificador: '#GAS1',
    nome: 'Córrego Gasparinho',
    bairro: 'Gasparinho',
    endereco: 'Rua Pedro Simon',
    numeroReferencia: 'Em frente ao nº 240',
    descricaoDoTrecho: 'Trecho de 400 m.',
    larguraMetros: larguraMetros,
    profundidadeMetros: profundidadeMetros,
    velocidadeMetrosPorSegundo: velocidadeMetrosPorSegundo,
    dosagemMl: 120,
    distanciaEntreSubpontosMetros: 50,
    quantidadeDeSubpontos: 8,
    aplicadorId: aplicadorId,
    estado: estado,
    subpontos: subpontos,
  );
}

final _execucao = Subponto(
  latitude: -26.9312,
  longitude: -48.9567,
  realizadoEm: DateTime(2026, 8, 24, 8, 12),
  registradoEm: DateTime(2026, 8, 24, 18, 40),
);

void main() {
  group('vazão', () {
    test('é o produto dos três parâmetros hidrológicos brutos', () {
      final ponto = pontoDeTeste(
        larguraMetros: 2,
        profundidadeMetros: 0.5,
        velocidadeMetrosPorSegundo: 0.4,
      );

      expect(ponto.vazao, closeTo(0.4, 0.0001));
    });

    test('acompanha a alteração dos parâmetros, sem valor persistido', () {
      final ponto = pontoDeTeste().copyWith(larguraMetros: 4);

      expect(ponto.vazao, closeTo(0.8, 0.0001));
    });
  });

  group('invariantes de estado', () {
    test('ponto ativo sem aplicador é rejeitado na construção', () {
      expect(
        () => pontoDeTeste(estado: EstadoPontoDeAplicacao.ativa),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });

    test('ponto ativo com aplicador é aceito', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.ativa,
        aplicadorId: '1',
      );

      expect(ponto.estado, EstadoPontoDeAplicacao.ativa);
    });

    test('desatribuir aplicador de um ponto ativo é rejeitado', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.ativa,
        aplicadorId: '1',
      );

      expect(
        ponto.desatribuirAplicador,
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });

    test('desatribuir de um ponto direcionado devolve a endereçada', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.direcionada,
        aplicadorId: '1',
      ).desatribuirAplicador();

      expect(ponto.aplicadorId, isNull);
      expect(ponto.estado, EstadoPontoDeAplicacao.enderecada);
    });

    test('atribuir aplicador promove endereçada a direcionada', () {
      final ponto = pontoDeTeste().atribuirAplicador('2');

      expect(ponto.aplicadorId, '2');
      expect(ponto.estado, EstadoPontoDeAplicacao.direcionada);
    });

    test('atribuir aplicador não altera o estado de um ponto inativo', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.inativa,
      ).atribuirAplicador('2');

      expect(ponto.estado, EstadoPontoDeAplicacao.inativa);
    });
  });

  group('execuções', () {
    test('ponto ativo sem execução é sinalizado como alerta', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.ativa,
        aplicadorId: '1',
      );

      expect(ponto.ativoSemRegistro, isTrue);
      expect(ponto.primeiraExecucao, isNull);
    });

    test('ponto ativo com execução registrada não vira alerta', () {
      final ponto = pontoDeTeste(
        estado: EstadoPontoDeAplicacao.ativa,
        aplicadorId: '1',
        subpontos: [_execucao],
      );

      expect(ponto.ativoSemRegistro, isFalse);
      expect(ponto.primeiraExecucao, _execucao);
    });

    test('ponto endereçado sem execução não é alerta (não está em operação)', () {
      expect(pontoDeTeste().ativoSemRegistro, isFalse);
    });

    test('a lista de execuções não é modificável por fora da entidade', () {
      final ponto = pontoDeTeste(subpontos: [_execucao]);

      expect(() => ponto.subpontos.add(_execucao), throwsUnsupportedError);
    });
  });
}
