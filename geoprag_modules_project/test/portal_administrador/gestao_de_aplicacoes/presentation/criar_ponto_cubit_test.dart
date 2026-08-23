import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/criar_ponto_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/criar_ponto_state.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminPontoDeAplicacaoRepository extends Mock
    implements AdminPontoDeAplicacaoRepository {}

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

void main() {
  late MockAdminPontoDeAplicacaoRepository repository;
  late MockAplicadorRepository aplicadorRepository;

  setUp(() {
    repository = MockAdminPontoDeAplicacaoRepository();
    aplicadorRepository = MockAplicadorRepository();
  });

  blocTest<CriarPontoCubit, CriarPontoState>(
    'emite [Salvando, Sucesso] quando o repositório cria o ponto',
    setUp: () {
      when(
        () => repository.criar(
          bairro: 'Belchior',
          lat: -26.99,
          lng: -48.95,
          aplicadorId: null,
        ),
      ).thenAnswer(
        (_) async => const AdminPontoDeAplicacao(
          id: '7',
          bairro: 'Belchior',
          lat: -26.99,
          lng: -48.95,
          status: StatusPontoDeAplicacao.planejada,
        ),
      );
    },
    build: () => CriarPontoCubit(repository, aplicadorRepository),
    act: (cubit) => cubit.submit(bairro: 'Belchior', lat: -26.99, lng: -48.95),
    expect: () => [
      isA<CriarPontoSalvando>(),
      isA<CriarPontoSucesso>().having(
        (s) => s.ponto.status,
        'ponto.status',
        StatusPontoDeAplicacao.planejada,
      ),
    ],
  );

  blocTest<CriarPontoCubit, CriarPontoState>(
    'repassa uma distância de alerta customizada para o repositório',
    setUp: () {
      when(
        () => repository.criar(
          bairro: 'Belchior',
          lat: -26.99,
          lng: -48.95,
          aplicadorId: null,
          distanciaAlertaMetros: 80.0,
        ),
      ).thenAnswer(
        (_) async => const AdminPontoDeAplicacao(
          id: '7',
          bairro: 'Belchior',
          lat: -26.99,
          lng: -48.95,
          status: StatusPontoDeAplicacao.planejada,
          distanciaAlertaMetros: 80.0,
        ),
      );
    },
    build: () => CriarPontoCubit(repository, aplicadorRepository),
    act: (cubit) => cubit.submit(
      bairro: 'Belchior',
      lat: -26.99,
      lng: -48.95,
      distanciaAlertaMetros: 80.0,
    ),
    expect: () => [
      isA<CriarPontoSalvando>(),
      isA<CriarPontoSucesso>().having(
        (s) => s.ponto.distanciaAlertaMetros,
        'ponto.distanciaAlertaMetros',
        80.0,
      ),
    ],
    verify: (_) {
      verify(
        () => repository.criar(
          bairro: 'Belchior',
          lat: -26.99,
          lng: -48.95,
          aplicadorId: null,
          distanciaAlertaMetros: 80.0,
        ),
      ).called(1);
    },
  );

  blocTest<CriarPontoCubit, CriarPontoState>(
    'emite [Salvando, Erro] com mensagem genérica quando a criação falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.criar(
          bairro: 'Instável',
          lat: 0,
          lng: 0,
          aplicadorId: null,
        ),
      ).thenAnswer((_) async => throw Exception('timeout'));
    },
    build: () => CriarPontoCubit(repository, aplicadorRepository),
    act: (cubit) => cubit.submit(bairro: 'Instável', lat: 0, lng: 0),
    expect: () => [
      isA<CriarPontoSalvando>(),
      isA<CriarPontoErro>().having(
        (s) => s.message,
        'message',
        AppErrorMessages.carregamentoGenerico,
      ),
    ],
  );
}
