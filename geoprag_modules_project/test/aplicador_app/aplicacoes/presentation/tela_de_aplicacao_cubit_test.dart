import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/aplicador_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/posicao_gps.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/registro_de_aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/servico_de_localizacao.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/tela_de_aplicacao_cubit.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/tela_de_aplicacao_state.dart';
import 'package:geoprag_modules/src/entities/aplicacao.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/entities/produto.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicadorPontoDeAplicacaoRepository extends Mock
    implements AplicadorPontoDeAplicacaoRepository {}

class MockRegistroDeAplicacaoRepository extends Mock
    implements RegistroDeAplicacaoRepository {}

class MockServicoDeLocalizacao extends Mock implements ServicoDeLocalizacao {}

void main() {
  late MockAplicadorPontoDeAplicacaoRepository pontos;
  late MockRegistroDeAplicacaoRepository registro;
  late MockServicoDeLocalizacao localizacao;

  final posicao = PosicaoGps(
    latitude: -26.9331,
    longitude: -48.9528,
    precisaoMetros: 8,
    instante: DateTime(2026, 10, 21, 9, 30),
  );

  const larvicida = Produto(id: 'produto-1', nome: 'Larvicida');
  const outro = Produto(id: 'produto-2', nome: 'Outro');

  PontoDeAplicacao pontoCom({bool comDataPendente = true}) => PontoDeAplicacao(
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
    quantidadeDeSubpontos: 2,
    aplicadorId: 'aplicador-1',
    estado: EstadoPontoDeAplicacao.ativa,
    agendamento: Agendamento(
      dataInicio: DateTime(2026, 10, 25),
      intervaloDias: 7,
      quantidadeRecorrencias: 2,
      datas: [
        DataAgendada(
          id: 'pa1-d1',
          data: DateTime(2026, 10, 25),
          status: comDataPendente
              ? StatusDataAgendada.pendente
              : StatusDataAgendada.concluida,
        ),
        DataAgendada(
          id: 'pa1-d2',
          data: DateTime(2026, 11, 1),
          status: StatusDataAgendada.concluida,
        ),
      ],
    ),
  );

  final aplicacaoAberta = Aplicacao(
    id: 'aplicacao-1',
    pontoId: 'pa1',
    aplicadorId: 'aplicador-1',
    dataAgendadaId: 'pa1-d1',
    produtoId: 'produto-1',
    realizadoEm: posicao.instante,
    localizacao: LocalizacaoCapturada(
      latitude: posicao.latitude,
      longitude: posicao.longitude,
    ),
  );

  Future<TelaDeAplicacaoCubit> criar({
    List<Produto> produtos = const [larvicida],
    PontoDeAplicacao? ponto,
  }) async {
    when(
      () => pontos.buscarPorId('pa1'),
    ).thenAnswer((_) async => ponto ?? pontoCom());
    when(() => registro.listarProdutos()).thenAnswer((_) async => produtos);
    final cubit = TelaDeAplicacaoCubit(
      pontos,
      registro,
      localizacao,
      'pa1',
      'aplicador-1',
    );
    await Future<void>.delayed(Duration.zero);
    return cubit;
  }

  TelaDeAplicacaoEmAndamento andamento(TelaDeAplicacaoCubit cubit) =>
      cubit.state as TelaDeAplicacaoEmAndamento;

  setUpAll(
    () => registerFallbackValue(
      const LocalizacaoCapturada(latitude: 0, longitude: 0),
    ),
  );

  setUp(() {
    pontos = MockAplicadorPontoDeAplicacaoRepository();
    registro = MockRegistroDeAplicacaoRepository();
    localizacao = MockServicoDeLocalizacao();
    when(() => localizacao.obterPosicao()).thenAnswer((_) async => posicao);
    when(
      () => registro.iniciarAplicacao(
        pontoId: any(named: 'pontoId'),
        aplicadorId: any(named: 'aplicadorId'),
        dataAgendadaId: any(named: 'dataAgendadaId'),
        produtoId: any(named: 'produtoId'),
        localizacao: any(named: 'localizacao'),
        realizadoEm: any(named: 'realizadoEm'),
      ),
    ).thenAnswer((_) async => aplicacaoAberta);
    when(
      () => registro.registrarSubponto(
        aplicacaoId: any(named: 'aplicacaoId'),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        realizadoEm: any(named: 'realizadoEm'),
      ),
    ).thenAnswer((_) async => aplicacaoAberta);
  });

  group('carregar', () {
    test('abre em andamento, com os produtos do aparelho', () async {
      final cubit = await criar(produtos: [larvicida, outro]);

      final estado = andamento(cubit);
      expect(estado.subpontosRegistrados, 0);
      expect(estado.concluida, isFalse);
      expect(estado.produtos, [larvicida, outro]);
      expect(estado.ponto.proximaDataAgendadaId, 'pa1-d1');
      await cubit.close();
    });

    test('com um só produto, ele já vem escolhido', () async {
      final cubit = await criar();

      expect(andamento(cubit).produtoSelecionadoId, 'produto-1');
      await cubit.close();
    });

    test('com vários produtos, nenhum vem escolhido', () async {
      final cubit = await criar(produtos: [larvicida, outro]);

      expect(andamento(cubit).produtoSelecionadoId, isNull);
      await cubit.close();
    });

    test('emite erro genérico quando o banco falha', () async {
      when(
        () => pontos.buscarPorId('pa1'),
      ).thenAnswer((_) async => throw Exception('banco'));
      when(() => registro.listarProdutos()).thenAnswer((_) async => []);
      final cubit = TelaDeAplicacaoCubit(
        pontos,
        registro,
        localizacao,
        'pa1',
        'aplicador-1',
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<TelaDeAplicacaoError>());
      await cubit.close();
    });

    test('ponto inexistente mostra a mensagem amigável', () async {
      when(() => pontos.buscarPorId('pa1')).thenThrow(
        const EntidadeNaoEncontradaException('Ponto não encontrado.'),
      );
      when(() => registro.listarProdutos()).thenAnswer((_) async => []);
      final cubit = TelaDeAplicacaoCubit(
        pontos,
        registro,
        localizacao,
        'pa1',
        'aplicador-1',
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        (cubit.state as TelaDeAplicacaoError).message,
        'Ponto não encontrado.',
      );
      await cubit.close();
    });
  });

  group('registrarSubponto', () {
    test('o primeiro subponto abre a aplicação com produto, data e GPS e '
        'registra o subponto nela', () async {
      final cubit = await criar();

      await cubit.registrarSubponto();

      verify(
        () => registro.iniciarAplicacao(
          pontoId: 'pa1',
          aplicadorId: 'aplicador-1',
          dataAgendadaId: 'pa1-d1',
          produtoId: 'produto-1',
          localizacao: LocalizacaoCapturada(
            latitude: posicao.latitude,
            longitude: posicao.longitude,
          ),
          realizadoEm: posicao.instante,
        ),
      ).called(1);
      verify(
        () => registro.registrarSubponto(
          aplicacaoId: 'aplicacao-1',
          latitude: posicao.latitude,
          longitude: posicao.longitude,
          realizadoEm: posicao.instante,
        ),
      ).called(1);
      expect(andamento(cubit).subpontosRegistrados, 1);
      expect(andamento(cubit).registrando, isFalse);
      await cubit.close();
    });

    test('os subpontos seguintes reaproveitam a mesma aplicação', () async {
      final cubit = await criar();

      await cubit.registrarSubponto();
      await cubit.registrarSubponto();

      verify(
        () => registro.iniciarAplicacao(
          pontoId: any(named: 'pontoId'),
          aplicadorId: any(named: 'aplicadorId'),
          dataAgendadaId: any(named: 'dataAgendadaId'),
          produtoId: any(named: 'produtoId'),
          localizacao: any(named: 'localizacao'),
          realizadoEm: any(named: 'realizadoEm'),
        ),
      ).called(1);
      verify(
        () => registro.registrarSubponto(
          aplicacaoId: 'aplicacao-1',
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          realizadoEm: any(named: 'realizadoEm'),
        ),
      ).called(2);
      await cubit.close();
    });

    test('concluida fica true ao atingir a quantidade de subpontos (2) e '
        'um terceiro registro é ignorado', () async {
      final cubit = await criar();

      await cubit.registrarSubponto();
      expect(andamento(cubit).concluida, isFalse);
      await cubit.registrarSubponto();
      expect(andamento(cubit).concluida, isTrue);
      await cubit.registrarSubponto();

      expect(andamento(cubit).subpontosRegistrados, 2);
      verify(
        () => registro.registrarSubponto(
          aplicacaoId: any(named: 'aplicacaoId'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          realizadoEm: any(named: 'realizadoEm'),
        ),
      ).called(2);
      await cubit.close();
    });

    test('sem produto escolhido não registra e pede a escolha', () async {
      final cubit = await criar(produtos: [larvicida, outro]);

      await cubit.registrarSubponto();

      expect(andamento(cubit).mensagemDeErro, isNotNull);
      expect(andamento(cubit).subpontosRegistrados, 0);
      verifyNever(() => localizacao.obterPosicao());
      await cubit.close();
    });

    test('escolher o produto libera o registro e o fixa depois do '
        'primeiro subponto', () async {
      final cubit = await criar(produtos: [larvicida, outro]);

      cubit.selecionarProduto('produto-2');
      expect(andamento(cubit).produtoSelecionadoId, 'produto-2');
      await cubit.registrarSubponto();
      cubit.selecionarProduto('produto-1');

      expect(andamento(cubit).produtoSelecionadoId, 'produto-2');
      verify(
        () => registro.iniciarAplicacao(
          pontoId: any(named: 'pontoId'),
          aplicadorId: any(named: 'aplicadorId'),
          dataAgendadaId: any(named: 'dataAgendadaId'),
          produtoId: 'produto-2',
          localizacao: any(named: 'localizacao'),
          realizadoEm: any(named: 'realizadoEm'),
        ),
      ).called(1);
      await cubit.close();
    });

    test('sem produto nenhum no aparelho não registra', () async {
      final cubit = await criar(produtos: const []);

      await cubit.registrarSubponto();

      expect(andamento(cubit).subpontosRegistrados, 0);
      expect(andamento(cubit).mensagemDeErro, isNotNull);
      await cubit.close();
    });

    test('sem data pendente não registra e orienta a sincronizar', () async {
      final cubit = await criar(ponto: pontoCom(comDataPendente: false));

      await cubit.registrarSubponto();

      expect(andamento(cubit).subpontosRegistrados, 0);
      expect(andamento(cubit).mensagemDeErro, contains('Sincronize'));
      verifyNever(() => localizacao.obterPosicao());
      await cubit.close();
    });

    for (final motivo in MotivoSemPosicao.values) {
      test('sem posição ($motivo) não registra, orienta e deixa tentar de '
          'novo', () async {
        final cubit = await criar();
        when(
          () => localizacao.obterPosicao(),
        ).thenThrow(PosicaoIndisponivelException(motivo));

        await cubit.registrarSubponto();

        verifyNever(
          () => registro.iniciarAplicacao(
            pontoId: any(named: 'pontoId'),
            aplicadorId: any(named: 'aplicadorId'),
            dataAgendadaId: any(named: 'dataAgendadaId'),
            produtoId: any(named: 'produtoId'),
            localizacao: any(named: 'localizacao'),
            realizadoEm: any(named: 'realizadoEm'),
          ),
        );
        expect(andamento(cubit).subpontosRegistrados, 0);
        expect(andamento(cubit).registrando, isFalse);
        expect(
          andamento(cubit).mensagemDeErro,
          PosicaoIndisponivelException(motivo).mensagemAmigavel,
        );

        when(() => localizacao.obterPosicao()).thenAnswer((_) async => posicao);
        await cubit.registrarSubponto();

        expect(andamento(cubit).subpontosRegistrados, 1);
        expect(andamento(cubit).mensagemDeErro, isNull);
        await cubit.close();
      });
    }

    test('falha ao gravar o subponto não perde a aplicação aberta: a nova '
        'tentativa registra na mesma', () async {
      final cubit = await criar();
      when(
        () => registro.registrarSubponto(
          aplicacaoId: any(named: 'aplicacaoId'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          realizadoEm: any(named: 'realizadoEm'),
        ),
      ).thenAnswer((_) async => throw Exception('disco cheio'));

      await cubit.registrarSubponto();

      expect(andamento(cubit).subpontosRegistrados, 0);
      expect(andamento(cubit).registrando, isFalse);

      when(
        () => registro.registrarSubponto(
          aplicacaoId: any(named: 'aplicacaoId'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          realizadoEm: any(named: 'realizadoEm'),
        ),
      ).thenAnswer((_) async => aplicacaoAberta);
      await cubit.registrarSubponto();

      expect(andamento(cubit).subpontosRegistrados, 1);
      verify(
        () => registro.iniciarAplicacao(
          pontoId: any(named: 'pontoId'),
          aplicadorId: any(named: 'aplicadorId'),
          dataAgendadaId: any(named: 'dataAgendadaId'),
          produtoId: any(named: 'produtoId'),
          localizacao: any(named: 'localizacao'),
          realizadoEm: any(named: 'realizadoEm'),
        ),
      ).called(1);
      await cubit.close();
    });

    test('fechar a tela durante a leitura do GPS não gera erro', () async {
      final cubit = await criar();
      final leitura = Completer<PosicaoGps>();
      when(() => localizacao.obterPosicao()).thenAnswer((_) => leitura.future);

      final registrando = cubit.registrarSubponto();
      await cubit.close();
      leitura.complete(posicao);

      await expectLater(registrando, completes);
    });
  });
}
