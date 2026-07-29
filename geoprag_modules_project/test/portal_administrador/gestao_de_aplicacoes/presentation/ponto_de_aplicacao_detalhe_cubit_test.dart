import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/ponto_de_aplicacao_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/ponto_de_aplicacao_detalhe_state.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminPontoDeAplicacaoRepository extends Mock
    implements AdminPontoDeAplicacaoRepository {}

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

void main() {
  late MockAdminPontoDeAplicacaoRepository repository;
  late MockAplicadorRepository aplicadorRepository;

  final ponto = AdminPontoDeAplicacao(
    id: '1',
    bairro: 'Belchior',
    lat: -26.99,
    lng: -48.95,
    status: StatusPontoDeAplicacao.planejada,
    aplicadorId: '1',
  );

  final aplicador = Aplicador(
    id: '1',
    nome: 'João Silva',
    bairro: 'Belchior',
    status: 'ativo',
    dataCadastro: DateTime(2026, 5, 10),
    cpf: '111.111.111-11',
    telefone: '(47) 99111-1111',
    endereco: 'Rua das Flores, 50 - Belchior',
  );

  setUp(() {
    repository = MockAdminPontoDeAplicacaoRepository();
    aplicadorRepository = MockAplicadorRepository();
    when(() => repository.buscarPorId('1')).thenAnswer((_) async => ponto);
    when(
      () => aplicadorRepository.listar(),
    ).thenAnswer((_) async => [aplicador]);
  });

  blocTest<PontoDeAplicacaoDetalheCubit, PontoDeAplicacaoDetalheState>(
    'emite [Loaded] com o nome do aplicador já resolvido',
    build: () =>
        PontoDeAplicacaoDetalheCubit(repository, aplicadorRepository, '1'),
    expect: () => [
      isA<PontoDeAplicacaoDetalheLoaded>().having(
        (s) => s.ponto.nomeDoAplicador,
        'ponto.nomeDoAplicador',
        'João Silva',
      ),
    ],
  );

  blocTest<PontoDeAplicacaoDetalheCubit, PontoDeAplicacaoDetalheState>(
    'emite [Error] com mensagem amigável quando o ponto não é encontrado '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.buscarPorId('inexistente'),
      ).thenThrow(
        const EntidadeNaoEncontradaException('Ponto de aplicação "inexistente" não encontrado.'),
      );
    },
    build: () => PontoDeAplicacaoDetalheCubit(
      repository,
      aplicadorRepository,
      'inexistente',
    ),
    expect: () => [
      isA<PontoDeAplicacaoDetalheError>().having(
        (s) => s.message,
        'message',
        'Ponto de aplicação "inexistente" não encontrado.',
      ),
    ],
  );

  blocTest<PontoDeAplicacaoDetalheCubit, PontoDeAplicacaoDetalheState>(
    'desativar chama o repositório e recarrega o ponto atualizado',
    setUp: () {
      when(
        () => repository.desativar('1'),
      ).thenAnswer((_) async => ponto.copyWith(ativo: false));
      when(
        () => repository.buscarPorId('1'),
      ).thenAnswer((_) async => ponto.copyWith(ativo: false));
    },
    build: () =>
        PontoDeAplicacaoDetalheCubit(repository, aplicadorRepository, '1'),
    act: (cubit) => cubit.desativar(),
    skip: 1,
    expect: () => [
      isA<PontoDeAplicacaoDetalheLoaded>().having(
        (s) => s.ponto.ativo,
        'ponto.ativo',
        isFalse,
      ),
    ],
    verify: (_) {
      verify(() => repository.desativar('1')).called(1);
    },
  );

  blocTest<PontoDeAplicacaoDetalheCubit, PontoDeAplicacaoDetalheState>(
    'atribuirAplicador chama o repositório com o novo id e recarrega',
    setUp: () {
      when(
        () => repository.atribuirAplicador('1', '2'),
      ).thenAnswer((_) async => ponto.copyWith(aplicadorId: () => '2'));
      when(() => repository.buscarPorId('1')).thenAnswer(
        (_) async => ponto.copyWith(aplicadorId: () => '2'),
      );
    },
    build: () =>
        PontoDeAplicacaoDetalheCubit(repository, aplicadorRepository, '1'),
    act: (cubit) => cubit.atribuirAplicador('2'),
    skip: 1,
    verify: (_) {
      verify(() => repository.atribuirAplicador('1', '2')).called(1);
    },
  );
}
