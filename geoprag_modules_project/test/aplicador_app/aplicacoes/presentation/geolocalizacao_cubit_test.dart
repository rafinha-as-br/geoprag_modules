import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/aplicador_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/posicao_gps.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/regra_de_chegada.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/servico_de_localizacao.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/geolocalizacao_cubit.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/geolocalizacao_state.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicadorPontoDeAplicacaoRepository extends Mock
    implements AplicadorPontoDeAplicacaoRepository {}

class MockServicoDeLocalizacao extends Mock implements ServicoDeLocalizacao {}

void main() {
  late MockAplicadorPontoDeAplicacaoRepository repository;
  late MockServicoDeLocalizacao localizacao;

  // Primeiro subponto já registrado do ponto: a referência da chegada.
  const latitudeDoPonto = -26.9331;
  const longitudeDoPonto = -48.9528;

  PosicaoGps posicaoA({required double metrosAoNorte}) => PosicaoGps(
    latitude: latitudeDoPonto + metrosAoNorte / 111195,
    longitude: longitudeDoPonto,
    precisaoMetros: 6,
    instante: DateTime(2026, 10, 21, 9),
  );

  PontoDeAplicacao pontoComSubpontos(List<Subponto> subpontos) =>
      PontoDeAplicacao(
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
        distanciaEntreSubpontosMetros: 75,
        quantidadeDeSubpontos: 8,
        aplicadorId: '1',
        estado: EstadoPontoDeAplicacao.ativa,
        subpontos: subpontos,
      );

  final primeiraAplicacao = pontoComSubpontos(const []);
  final revisita = pontoComSubpontos([
    Subponto(
      id: 'sp1',
      latitude: latitudeDoPonto,
      longitude: longitudeDoPonto,
      realizadoEm: DateTime(2026, 10, 1),
      registradoEm: DateTime(2026, 10, 1),
    ),
  ]);

  setUp(() {
    repository = MockAplicadorPontoDeAplicacaoRepository();
    localizacao = MockServicoDeLocalizacao();
  });

  GeolocalizacaoCubit build() =>
      GeolocalizacaoCubit(repository, localizacao, 'pa1');

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'primeira aplicação: confirma a chegada sem validar e sem ler o GPS',
    setUp: () {
      when(
        () => repository.buscarPorId('pa1'),
      ).thenAnswer((_) async => primeiraAplicacao);
    },
    build: build,
    expect: () => [
      isA<GeolocalizacaoLoaded>().having(
        (s) => s.verificacao,
        'verificacao',
        isA<ChegadaVerificando>(),
      ),
      isA<GeolocalizacaoLoaded>()
          .having((s) => s.dentroDoRaio, 'dentroDoRaio', true)
          .having(
            (s) => (s.verificacao as ChegadaConfirmada).distanciaMetros,
            'distanciaMetros',
            isNull,
          ),
    ],
    verify: (_) {
      verifyNever(() => localizacao.obterPosicao());
    },
  );

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'revisita dentro do raio: confirma a chegada com a distância medida',
    setUp: () {
      when(
        () => repository.buscarPorId('pa1'),
      ).thenAnswer((_) async => revisita);
      when(
        () => localizacao.obterPosicao(),
      ).thenAnswer((_) async => posicaoA(metrosAoNorte: 40));
    },
    build: build,
    skip: 1,
    expect: () => [
      isA<GeolocalizacaoLoaded>()
          .having((s) => s.dentroDoRaio, 'dentroDoRaio', true)
          .having(
            (s) => (s.verificacao as ChegadaConfirmada).distanciaMetros,
            'distanciaMetros',
            closeTo(40, 1),
          ),
    ],
  );

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'revisita fora do raio: bloqueia e informa a distância',
    setUp: () {
      when(
        () => repository.buscarPorId('pa1'),
      ).thenAnswer((_) async => revisita);
      when(
        () => localizacao.obterPosicao(),
      ).thenAnswer((_) async => posicaoA(metrosAoNorte: 250));
    },
    build: build,
    skip: 1,
    expect: () => [
      isA<GeolocalizacaoLoaded>()
          .having((s) => s.dentroDoRaio, 'dentroDoRaio', false)
          .having(
            (s) => (s.verificacao as ChegadaForaDoRaio).distanciaMetros,
            'distanciaMetros',
            closeTo(250, 1),
          ),
    ],
  );

  for (final motivo in MotivoSemPosicao.values) {
    blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
      'sem posição ($motivo): não confirma e orienta o aplicador',
      setUp: () {
        when(
          () => repository.buscarPorId('pa1'),
        ).thenAnswer((_) async => revisita);
        when(
          () => localizacao.obterPosicao(),
        ).thenThrow(PosicaoIndisponivelException(motivo));
      },
      build: build,
      skip: 1,
      expect: () => [
        isA<GeolocalizacaoLoaded>()
            .having((s) => s.dentroDoRaio, 'dentroDoRaio', false)
            .having(
              (s) => (s.verificacao as ChegadaSemPosicao).mensagem,
              'mensagem',
              PosicaoIndisponivelException(motivo).mensagemAmigavel,
            ),
      ],
    );
  }

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'erro inesperado ao ler o GPS vira orientação, nunca exceção bruta',
    setUp: () {
      when(
        () => repository.buscarPorId('pa1'),
      ).thenAnswer((_) async => revisita);
      when(() => localizacao.obterPosicao()).thenThrow(Exception('plugin'));
    },
    build: build,
    skip: 1,
    expect: () => [
      isA<GeolocalizacaoLoaded>().having(
        (s) => (s.verificacao as ChegadaSemPosicao).mensagem,
        'mensagem',
        isNot(contains('Exception')),
      ),
    ],
  );

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'verificarChegada de novo, depois de ficar fora do raio, lê o GPS outra vez',
    setUp: () {
      when(
        () => repository.buscarPorId('pa1'),
      ).thenAnswer((_) async => revisita);
      when(
        () => localizacao.obterPosicao(),
      ).thenAnswer((_) async => posicaoA(metrosAoNorte: 250));
    },
    build: build,
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      when(
        () => localizacao.obterPosicao(),
      ).thenAnswer((_) async => posicaoA(metrosAoNorte: 30));
      await cubit.verificarChegada();
    },
    skip: 2,
    expect: () => [
      isA<GeolocalizacaoLoaded>().having(
        (s) => s.verificacao,
        'verificacao',
        isA<ChegadaVerificando>(),
      ),
      isA<GeolocalizacaoLoaded>().having(
        (s) => s.dentroDoRaio,
        'dentroDoRaio',
        true,
      ),
    ],
  );

  blocTest<GeolocalizacaoCubit, GeolocalizacaoState>(
    'emite [Error] com mensagem amigável quando falha ao carregar '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.buscarPorId('pa1'),
      ).thenAnswer((_) async => throw Exception('offline'));
    },
    build: build,
    expect: () => [
      isA<GeolocalizacaoError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
    verify: (_) {
      verifyNever(() => localizacao.obterPosicao());
    },
  );

  test('o raio de chegada provisório é de 100 m, num único lugar', () {
    expect(RegraDeChegada.raioDeChegadaMetros, 100);
  });
}
