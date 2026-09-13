import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/aplicador_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/meus_pontos_cubit.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/meus_pontos_state.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicadorPontoDeAplicacaoRepository extends Mock
    implements AplicadorPontoDeAplicacaoRepository {}

void main() {
  late MockAplicadorPontoDeAplicacaoRepository repository;

  PontoDeAplicacao ponto({
    required String id,
    required String nome,
    required EstadoPontoDeAplicacao estado,
    List<Subponto> subpontos = const [],
  }) {
    return PontoDeAplicacao(
      id: id,
      identificador: '#$id',
      nome: nome,
      bairro: 'Gasparinho',
      endereco: 'Rua Teste',
      numeroReferencia: 'S/N',
      descricaoDoTrecho: 'Trecho de teste.',
      larguraMetros: 2,
      profundidadeMetros: 0.5,
      velocidadeMetrosPorSegundo: 0.4,
      dosagemMl: 100,
      distanciaEntreSubpontosMetros: 50,
      quantidadeDeSubpontos: 4,
      aplicadorId: '1',
      estado: estado,
      subpontos: subpontos,
    );
  }

  setUp(() {
    repository = MockAplicadorPontoDeAplicacaoRepository();
  });

  blocTest<MeusPontosCubit, MeusPontosState>(
    'emite [Loaded] ordenado por urgência: ativo sem registro primeiro, '
    'depois ativo com histórico, depois direcionado, depois inativo',
    setUp: () {
      when(() => repository.listarMeusPontos('1')).thenAnswer(
        (_) async => [
          ponto(id: 'inativo', nome: 'Z Inativo', estado: EstadoPontoDeAplicacao.inativa),
          ponto(id: 'direcionado', nome: 'Y Direcionado', estado: EstadoPontoDeAplicacao.direcionada),
          ponto(
            id: 'ativoComHistorico',
            nome: 'X Ativo',
            estado: EstadoPontoDeAplicacao.ativa,
            subpontos: [
              Subponto(
                latitude: 0,
                longitude: 0,
                realizadoEm: DateTime(2026, 1, 1),
                registradoEm: DateTime(2026, 1, 1),
              ),
            ],
          ),
          ponto(id: 'ativoSemRegistro', nome: 'W Alerta', estado: EstadoPontoDeAplicacao.ativa),
        ],
      );
    },
    build: () => MeusPontosCubit(repository, '1'),
    expect: () => [
      isA<MeusPontosLoaded>().having(
        (s) => s.pontos.map((p) => p.id).toList(),
        'ordem dos ids',
        ['ativoSemRegistro', 'ativoComHistorico', 'direcionado', 'inativo'],
      ),
    ],
  );

  blocTest<MeusPontosCubit, MeusPontosState>(
    'emite [Error] com mensagem genérica quando falha ao carregar',
    setUp: () {
      when(() => repository.listarMeusPontos('1'))
          .thenAnswer((_) async => throw Exception('offline'));
    },
    build: () => MeusPontosCubit(repository, '1'),
    expect: () => [isA<MeusPontosError>()],
  );

  test('carregar recarrega a lista do zero', () async {
    when(() => repository.listarMeusPontos('1')).thenAnswer((_) async => []);
    final cubit = MeusPontosCubit(repository, '1');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, isA<MeusPontosLoaded>());

    await cubit.carregar();

    expect(cubit.state, isA<MeusPontosLoaded>());
    verify(() => repository.listarMeusPontos('1')).called(2);
  });
}
