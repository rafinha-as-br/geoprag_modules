import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/aplicador_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/meus_pontos_cubit.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/meus_pontos_state.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/core/resultado_da_sincronizacao.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/core/servico_de_sincronizacao.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicadorPontoDeAplicacaoRepository extends Mock
    implements AplicadorPontoDeAplicacaoRepository {}

class MockServicoDeSincronizacao extends Mock
    implements ServicoDeSincronizacao {}

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
    when(
      () => repository.idsDePontosEmAtraso(any()),
    ).thenAnswer((_) async => <String>{});
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
                id: 'sp-teste-1',
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

  blocTest<MeusPontosCubit, MeusPontosState>(
    'marca em atraso só os pontos que o repository aponta (GEOPRAG-161)',
    setUp: () {
      when(() => repository.listarMeusPontos('1')).thenAnswer(
        (_) async => [
          ponto(id: 'atrasado', nome: 'A', estado: EstadoPontoDeAplicacao.ativa),
          ponto(id: 'emDia', nome: 'B', estado: EstadoPontoDeAplicacao.ativa),
        ],
      );
      when(
        () => repository.idsDePontosEmAtraso('1'),
      ).thenAnswer((_) async => {'atrasado'});
    },
    build: () => MeusPontosCubit(repository, '1'),
    expect: () => [
      isA<MeusPontosLoaded>().having(
        (s) => {for (final p in s.pontos) p.id: p.emAtraso},
        'emAtraso por id',
        {'atrasado': true, 'emDia': false},
      ),
    ],
  );

  group('primeira carga e sincronização (GEOPRAG-203)', () {
    late MockServicoDeSincronizacao sincronizacao;
    late StreamController<void> aoSincronizar;

    final umPonto = ponto(
      id: 'p1',
      nome: 'A',
      estado: EstadoPontoDeAplicacao.ativa,
    );

    setUp(() {
      sincronizacao = MockServicoDeSincronizacao();
      aoSincronizar = StreamController<void>.broadcast();
      addTearDown(aoSincronizar.close);
    });

    MeusPontosCubit criar() => MeusPontosCubit(
      repository,
      '1',
      sincronizacao: sincronizacao,
      aoSincronizar: aoSincronizar.stream,
    );

    test('com pontos no aparelho mostra a lista sem sincronizar', () async {
      when(
        () => repository.listarMeusPontos('1'),
      ).thenAnswer((_) async => [umPonto]);
      final cubit = criar();

      await cubit.stream.firstWhere((s) => s is MeusPontosLoaded);

      verifyNever(() => sincronizacao.sincronizar());
      await cubit.close();
    });

    test('aparelho vazio: carrega, sincroniza e mostra o que o pull trouxe', () async {
      var chamadas = 0;
      when(() => repository.listarMeusPontos('1')).thenAnswer(
        (_) async => chamadas++ == 0 ? <PontoDeAplicacao>[] : [umPonto],
      );
      when(
        () => sincronizacao.sincronizar(),
      ).thenAnswer((_) async => const ResultadoDaSincronizacao());
      final cubit = criar();

      final estado = await cubit.stream.firstWhere(
        (s) => s is! MeusPontosLoading,
      );

      expect((estado as MeusPontosLoaded).pontos.map((p) => p.id), ['p1']);
      verify(() => sincronizacao.sincronizar()).called(1);
      await cubit.close();
    });

    test('aparelho vazio e a sincronização funcionou: lista vazia, sem erro', () async {
      when(() => repository.listarMeusPontos('1')).thenAnswer((_) async => []);
      when(
        () => sincronizacao.sincronizar(),
      ).thenAnswer((_) async => const ResultadoDaSincronizacao());
      final cubit = criar();

      final estado = await cubit.stream.firstWhere((s) => s is! MeusPontosLoading);

      expect((estado as MeusPontosLoaded).pontos, isEmpty);
      await cubit.close();
    });

    test('aparelho vazio e sem rede: erro de conexão, não lista vazia', () async {
      when(() => repository.listarMeusPontos('1')).thenAnswer((_) async => []);
      when(() => sincronizacao.sincronizar()).thenAnswer(
        (_) async => const ResultadoDaSincronizacao(pullFalhou: true),
      );
      final cubit = criar();

      final estado = await cubit.stream.firstWhere((s) => s is! MeusPontosLoading);

      expect(estado, isA<MeusPontosError>());
      await cubit.close();
    });

    test('a sincronização lançar também é erro, não trava a tela', () async {
      when(() => repository.listarMeusPontos('1')).thenAnswer((_) async => []);
      when(
        () => sincronizacao.sincronizar(),
      ).thenAnswer((_) async => throw Exception('inesperado'));
      final cubit = criar();

      final estado = await cubit.stream.firstWhere((s) => s is! MeusPontosLoading);

      expect(estado, isA<MeusPontosError>());
      await cubit.close();
    });

    test('sincronização que termina depois relê a lista sem passar pelo '
        'carregamento', () async {
      var pontos = <PontoDeAplicacao>[umPonto];
      when(
        () => repository.listarMeusPontos('1'),
      ).thenAnswer((_) async => pontos);
      final cubit = criar();
      await cubit.stream.firstWhere((s) => s is MeusPontosLoaded);

      pontos = [
        umPonto,
        ponto(id: 'p2', nome: 'B', estado: EstadoPontoDeAplicacao.ativa),
      ];
      aoSincronizar.add(null);
      final estado = await cubit.stream.first;

      expect(estado, isA<MeusPontosLoaded>());
      expect((estado as MeusPontosLoaded).pontos, hasLength(2));
      await cubit.close();
    });

    test('em erro e ainda sem pontos, uma sincronização automática não troca '
        'o erro por lista vazia', () async {
      when(() => repository.listarMeusPontos('1')).thenAnswer((_) async => []);
      when(() => sincronizacao.sincronizar()).thenAnswer(
        (_) async => const ResultadoDaSincronizacao(pullFalhou: true),
      );
      final cubit = criar();
      await cubit.stream.firstWhere((s) => s is MeusPontosError);

      aoSincronizar.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(cubit.state, isA<MeusPontosError>());
      await cubit.close();
    });

    test('tentar de novo (carregar) depois do erro mostra os pontos', () async {
      var pontos = <PontoDeAplicacao>[];
      when(
        () => repository.listarMeusPontos('1'),
      ).thenAnswer((_) async => pontos);
      var rede = false;
      when(() => sincronizacao.sincronizar()).thenAnswer((_) async {
        if (rede) pontos = [umPonto];
        return ResultadoDaSincronizacao(pullFalhou: !rede);
      });
      final cubit = criar();
      await cubit.stream.firstWhere((s) => s is MeusPontosError);

      rede = true;
      await cubit.carregar();

      expect(cubit.state, isA<MeusPontosLoaded>());
      await cubit.close();
    });
  });
}
