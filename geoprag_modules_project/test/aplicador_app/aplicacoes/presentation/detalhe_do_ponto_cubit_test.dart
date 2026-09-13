import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/aplicador_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/detalhe_do_ponto_cubit.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/detalhe_do_ponto_state.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicadorPontoDeAplicacaoRepository extends Mock
    implements AplicadorPontoDeAplicacaoRepository {}

void main() {
  late MockAplicadorPontoDeAplicacaoRepository repository;

  final ponto = PontoDeAplicacao(
    id: 'pa1',
    identificador: '#GAS1',
    nome: 'Córrego Gasparinho',
    bairro: 'Gasparinho',
    endereco: 'Rua Pedro Simon',
    numeroReferencia: 'Em frente ao nº 240',
    descricaoDoTrecho: 'Trecho de 400 m.',
    larguraMetros: 2,
    profundidadeMetros: 0.5,
    velocidadeMetrosPorSegundo: 0.4,
    dosagemMl: 120,
    distanciaEntreSubpontosMetros: 50,
    quantidadeDeSubpontos: 8,
    aplicadorId: '1',
    estado: EstadoPontoDeAplicacao.ativa,
  );

  setUp(() {
    repository = MockAplicadorPontoDeAplicacaoRepository();
  });

  blocTest<DetalheDoPontoDesignadoCubit, DetalheDoPontoDesignadoState>(
    'emite [Loaded] com o ponto correspondente',
    setUp: () {
      when(() => repository.buscarPorId('pa1')).thenAnswer((_) async => ponto);
    },
    build: () => DetalheDoPontoDesignadoCubit(repository, 'pa1'),
    expect: () => [
      isA<DetalheDoPontoDesignadoLoaded>().having(
        (s) => s.ponto.id,
        'ponto.id',
        'pa1',
      ),
    ],
  );

  blocTest<DetalheDoPontoDesignadoCubit, DetalheDoPontoDesignadoState>(
    'emite [Error] com mensagem amigável quando o ponto não existe',
    setUp: () {
      when(() => repository.buscarPorId('inexistente')).thenAnswer(
        (_) async => throw const EntidadeNaoEncontradaException(
          'Ponto de aplicação "inexistente" não encontrado.',
        ),
      );
    },
    build: () => DetalheDoPontoDesignadoCubit(repository, 'inexistente'),
    expect: () => [
      isA<DetalheDoPontoDesignadoError>().having(
        (s) => s.message,
        'message',
        'Ponto de aplicação "inexistente" não encontrado.',
      ),
    ],
  );

  blocTest<DetalheDoPontoDesignadoCubit, DetalheDoPontoDesignadoState>(
    'emite [Error] com mensagem genérica (nunca vaza a exceção bruta)',
    setUp: () {
      when(() => repository.buscarPorId('pa1'))
          .thenAnswer((_) async => throw Exception('offline'));
    },
    build: () => DetalheDoPontoDesignadoCubit(repository, 'pa1'),
    expect: () => [
      isA<DetalheDoPontoDesignadoError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
