import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/admin_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/ponto_de_aplicacao_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/ponto_de_aplicacao_detalhe_state.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/entities/usuario.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

import '../gestao_de_aplicacoes_fixtures.dart';

class MockAdminPontoDeAplicacaoRepository extends Mock
    implements AdminPontoDeAplicacaoRepository {}

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

void main() {
  late MockAdminPontoDeAplicacaoRepository repository;
  late MockAplicadorRepository aplicadorRepository;

  final aplicador = Aplicador(
    id: '1',
    nome: 'João Silva',
    status: UsuarioStatus.ativo,
    dataCriacao: DateTime(2026, 5, 10),
    email: 'joao.silva@email.com',
    cpf: '111.111.111-11',
    dataNascimento: DateTime(1988, 4, 12),
    sexo: 'Masculino',
    telefone: '(47) 99111-1111',
    cep: '89010-000',
    rua: 'Rua das Flores',
    numero: '50',
    bairro: 'Belchior',
    cidade: 'Blumenau',
    uf: 'SC',
  );

  setUp(() {
    repository = MockAdminPontoDeAplicacaoRepository();
    aplicadorRepository = MockAplicadorRepository();
  });

  Future<PontoDeAplicacaoDetalheCubit> carregar(PontoDeAplicacao ponto) async {
    when(() => repository.buscarPorId('pa1')).thenAnswer((_) async => ponto);
    when(
      () => aplicadorRepository.buscarPorId('1'),
    ).thenAnswer((_) async => aplicador);
    final cubit = PontoDeAplicacaoDetalheCubit(
      repository,
      aplicadorRepository,
      'pa1',
    );
    await Future<void>.delayed(Duration.zero);
    return cubit;
  }

  test('carrega o ponto com a vazão derivada dos parâmetros brutos', () async {
    final cubit = await carregar(
      pontoDeAplicacao(
        larguraMetros: 2,
        profundidadeMetros: 0.5,
        velocidadeMetrosPorSegundo: 0.4,
      ),
    );

    final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
    expect(state.ponto.vazao, closeTo(0.4, 0.0001));
  });

  test('resolve o nome do aplicador quando o ponto está direcionado', () async {
    final cubit = await carregar(
      pontoDeAplicacao(
        estado: EstadoPontoDeAplicacao.direcionada,
        aplicadorId: '1',
      ),
    );

    final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
    expect(state.ponto.aplicadorNome, 'João Silva');
  });

  test('não consulta aplicador nenhum quando o ponto não foi direcionado',
      () async {
    final cubit = await carregar(pontoDeAplicacao());

    final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
    expect(state.ponto.aplicadorNome, isNull);
    verifyNever(() => aplicadorRepository.buscarPorId(any()));
  });

  test('aplicador vinculado que sumiu do cadastro não derruba a tela do ponto',
      () async {
    when(() => repository.buscarPorId('pa1')).thenAnswer(
      (_) async => pontoDeAplicacao(
        estado: EstadoPontoDeAplicacao.direcionada,
        aplicadorId: '9',
      ),
    );
    when(() => aplicadorRepository.buscarPorId('9')).thenAnswer(
      (_) async =>
          throw const EntidadeNaoEncontradaException('Aplicador não existe.'),
    );

    final cubit = PontoDeAplicacaoDetalheCubit(
      repository,
      aplicadorRepository,
      'pa1',
    );
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as PontoDeAplicacaoDetalheLoaded;
    expect(state.ponto.id, 'pa1');
    expect(state.ponto.aplicadorNome, isNull);
  });

  test('mostra a mensagem de negócio quando o ponto não existe', () async {
    when(() => repository.buscarPorId('pa1')).thenAnswer(
      (_) async => throw const EntidadeNaoEncontradaException(
        'Ponto de aplicação "pa1" não encontrado.',
      ),
    );

    final cubit = PontoDeAplicacaoDetalheCubit(
      repository,
      aplicadorRepository,
      'pa1',
    );
    await Future<void>.delayed(Duration.zero);

    expect(
      (cubit.state as PontoDeAplicacaoDetalheError).message,
      'Ponto de aplicação "pa1" não encontrado.',
    );
  });

  test('erro inesperado vira mensagem genérica, sem vazar a exceção bruta',
      () async {
    when(
      () => repository.buscarPorId('pa1'),
    ).thenAnswer((_) async => throw Exception('offline'));

    final cubit = PontoDeAplicacaoDetalheCubit(
      repository,
      aplicadorRepository,
      'pa1',
    );
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as PontoDeAplicacaoDetalheError;
    expect(state.message, isNot(contains('Exception')));
  });
}
