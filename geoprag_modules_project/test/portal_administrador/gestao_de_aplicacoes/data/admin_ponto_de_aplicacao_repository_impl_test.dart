import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/admin_ponto_de_aplicacao_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/mock_pontos_de_aplicacao.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

void main() {
  late AdminPontoDeAplicacaoRepositoryImpl repository;
  late List<PontoDeAplicacao> snapshotOriginal;

  setUp(() {
    repository = AdminPontoDeAplicacaoRepositoryImpl();
    snapshotOriginal = List.of(mockPontosDeAplicacao);
  });

  // A fonte mockada é uma lista global: sem isso, um `criar` (que adiciona)
  // ou um `ativar`/`desativar`/`atribuirAplicador` (que substitui um item
  // existente) vazaria para os demais testes do arquivo.
  tearDown(() {
    mockPontosDeAplicacao
      ..clear()
      ..addAll(snapshotOriginal);
  });

  Future<PontoDeAplicacao> criar({
    String? aplicadorId,
    String bairro = 'Gasparinho',
  }) => repository.criar(
    nome: 'Córrego Novo',
    bairro: bairro,
    endereco: 'Rua Nova',
    numeroReferencia: 'Sem número',
    descricaoDoTrecho: 'Trecho de teste.',
    larguraMetros: 2,
    profundidadeMetros: 0.5,
    velocidadeMetrosPorSegundo: 0.4,
    dosagemMl: 100,
    distanciaEntreSubpontosMetros: 50,
    quantidadeDeSubpontos: 4,
    aplicadorId: aplicadorId,
  );

  test('listarPorBairro devolve só os pontos daquele bairro', () async {
    final pontos = await repository.listarPorBairro('Gasparinho');

    expect(pontos, isNotEmpty);
    expect(pontos.every((ponto) => ponto.bairro == 'Gasparinho'), isTrue);
  });

  test('buscarPorId falha com mensagem amigável quando o id não existe',
      () async {
    expect(
      () => repository.buscarPorId('inexistente'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });

  test('ponto criado sem aplicador nasce endereçado', () async {
    final ponto = await criar();

    expect(ponto.estado, EstadoPontoDeAplicacao.enderecada);
    expect(ponto.aplicadorId, isNull);
  });

  test('ponto criado com aplicador nasce direcionado', () async {
    final ponto = await criar(aplicadorId: '1');

    expect(ponto.estado, EstadoPontoDeAplicacao.direcionada);
    expect(ponto.aplicadorId, '1');
  });

  test('ponto criado nunca traz coordenada nem execução', () async {
    final ponto = await criar();

    expect(ponto.subpontos, isEmpty);
    expect(ponto.primeiraExecucao, isNull);
  });

  test('ponto criado entra na listagem do bairro', () async {
    await criar();

    final pontos = await repository.listarPorBairro('Gasparinho');
    expect(pontos.where((ponto) => ponto.nome == 'Córrego Novo'), hasLength(1));
  });

  group('ativar', () {
    test('ativa um ponto direcionado (pa3) com o agendamento informado', () async {
      final agendamento = Agendamento.gerar(
        dataInicio: DateTime(2026, 9, 10),
        intervaloDias: 15,
        quantidadeRecorrencias: 1,
      );

      await repository.ativar('pa3', agendamento);

      final ponto = await repository.buscarPorId('pa3');
      expect(ponto.estado, EstadoPontoDeAplicacao.ativa);
      expect(ponto.agendamento, agendamento);
    });

    test('falha com mensagem amigável quando o id não existe', () {
      expect(
        () => repository.ativar(
          'inexistente',
          Agendamento.gerar(
            dataInicio: DateTime(2026, 9, 10),
            intervaloDias: 15,
            quantidadeRecorrencias: 1,
          ),
        ),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });

    test('propaga a rejeição de domínio ao ativar um ponto endereçado (pa4)', () {
      expect(
        () => repository.ativar(
          'pa4',
          Agendamento.gerar(
            dataInicio: DateTime(2026, 9, 10),
            intervaloDias: 15,
            quantidadeRecorrencias: 1,
          ),
        ),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });
  });

  group('desativar', () {
    test('desativa um ponto ativo (pa2)', () async {
      await repository.desativar('pa2');

      final ponto = await repository.buscarPorId('pa2');
      expect(ponto.estado, EstadoPontoDeAplicacao.desativado);
    });

    test('falha com mensagem amigável quando o id não existe', () {
      expect(
        () => repository.desativar('inexistente'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });

    test('propaga a rejeição de domínio ao desativar um ponto já desativado (pa6)', () {
      expect(
        () => repository.desativar('pa6'),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });
  });

  group('atribuirAplicador', () {
    test('promove um ponto endereçado (pa4) a direcionado', () async {
      await repository.atribuirAplicador('pa4', '2');

      final ponto = await repository.buscarPorId('pa4');
      expect(ponto.aplicadorId, '2');
      expect(ponto.estado, EstadoPontoDeAplicacao.direcionada);
    });

    test('falha com mensagem amigável quando o id não existe', () {
      expect(
        () => repository.atribuirAplicador('inexistente', '2'),
        throwsA(isA<EntidadeNaoEncontradaException>()),
      );
    });
  });

  group('identificador do ponto criado', () {
    test('usa as três primeiras letras do bairro e a posição dentro dele', () async {
      // O mock já traz dois pontos em Gasparinho (#GAS1 e #GAS2).
      final ponto = await criar();

      expect(ponto.identificador, '#GAS3');
    });

    test('descarta espaços e caracteres acentuados do prefixo', () async {
      final ponto = await criar(bairro: 'Poço Grande');

      // Já existe um ponto em Poço Grande no mock.
      expect(ponto.identificador, '#POO2');
    });

    test('encurta o prefixo quando sobram menos de três letras', () async {
      final ponto = await criar(bairro: 'Sé');

      expect(ponto.identificador, '#S1');
    });
  });
}
