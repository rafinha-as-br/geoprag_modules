import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/aplicador_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/tela_de_aplicacao_cubit.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/presentation/tela_de_aplicacao_state.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
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
    quantidadeDeSubpontos: 2,
    aplicadorId: '1',
    estado: EstadoPontoDeAplicacao.ativa,
  );

  setUp(() {
    repository = MockAplicadorPontoDeAplicacaoRepository();
    registerFallbackValue(
      Subponto(
        latitude: 0,
        longitude: 0,
        realizadoEm: DateTime(2026),
        registradoEm: DateTime(2026),
      ),
    );
  });

  blocTest<TelaDeAplicacaoCubit, TelaDeAplicacaoState>(
    'emite [EmAndamento] com 0 subpontos registrados ao carregar',
    setUp: () {
      when(() => repository.buscarPorId('pa1')).thenAnswer((_) async => ponto);
    },
    build: () => TelaDeAplicacaoCubit(repository, 'pa1'),
    expect: () => [
      isA<TelaDeAplicacaoEmAndamento>()
          .having((s) => s.subpontosRegistrados, 'subpontosRegistrados', 0)
          .having((s) => s.concluida, 'concluida', false),
    ],
  );

  blocTest<TelaDeAplicacaoCubit, TelaDeAplicacaoState>(
    'emite [Error] com mensagem genérica quando falha ao carregar',
    setUp: () {
      when(() => repository.buscarPorId('pa1'))
          .thenAnswer((_) async => throw Exception('offline'));
    },
    build: () => TelaDeAplicacaoCubit(repository, 'pa1'),
    expect: () => [isA<TelaDeAplicacaoError>()],
  );

  blocTest<TelaDeAplicacaoCubit, TelaDeAplicacaoState>(
    'registrarSubponto soma um subponto e chama o repository',
    setUp: () {
      when(() => repository.buscarPorId('pa1')).thenAnswer((_) async => ponto);
      when(() => repository.registrarSubponto(any(), any()))
          .thenAnswer((_) async {});
    },
    build: () => TelaDeAplicacaoCubit(repository, 'pa1'),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      await cubit.registrarSubponto();
    },
    expect: () => [
      isA<TelaDeAplicacaoEmAndamento>()
          .having((s) => s.subpontosRegistrados, 'subpontosRegistrados', 0)
          .having((s) => s.registrando, 'registrando', false),
      isA<TelaDeAplicacaoEmAndamento>()
          .having((s) => s.subpontosRegistrados, 'subpontosRegistrados', 0)
          .having((s) => s.registrando, 'registrando', true),
      isA<TelaDeAplicacaoEmAndamento>()
          .having((s) => s.subpontosRegistrados, 'subpontosRegistrados', 1)
          .having((s) => s.registrando, 'registrando', false),
    ],
    verify: (_) {
      verify(() => repository.registrarSubponto('pa1', any())).called(1);
    },
  );

  blocTest<TelaDeAplicacaoCubit, TelaDeAplicacaoState>(
    'concluida fica true ao atingir a quantidade de subpontos do ponto (2)',
    setUp: () {
      when(() => repository.buscarPorId('pa1')).thenAnswer((_) async => ponto);
      when(() => repository.registrarSubponto(any(), any()))
          .thenAnswer((_) async {});
    },
    build: () => TelaDeAplicacaoCubit(repository, 'pa1'),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      await cubit.registrarSubponto();
      await cubit.registrarSubponto();
    },
    expect: () => [
      isA<TelaDeAplicacaoEmAndamento>().having((s) => s.subpontosRegistrados, '', 0),
      isA<TelaDeAplicacaoEmAndamento>().having((s) => s.subpontosRegistrados, '', 0),
      isA<TelaDeAplicacaoEmAndamento>().having((s) => s.subpontosRegistrados, '', 1),
      isA<TelaDeAplicacaoEmAndamento>().having((s) => s.subpontosRegistrados, '', 1),
      isA<TelaDeAplicacaoEmAndamento>()
          .having((s) => s.subpontosRegistrados, '', 2)
          .having((s) => s.concluida, 'concluida', true),
    ],
  );

  blocTest<TelaDeAplicacaoCubit, TelaDeAplicacaoState>(
    'registrarSubponto não faz nada quando a sessão já está concluída',
    setUp: () {
      when(() => repository.buscarPorId('pa1')).thenAnswer((_) async => ponto);
      when(() => repository.registrarSubponto(any(), any()))
          .thenAnswer((_) async {});
    },
    build: () => TelaDeAplicacaoCubit(repository, 'pa1'),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      await cubit.registrarSubponto();
      await cubit.registrarSubponto();
      await cubit.registrarSubponto();
    },
    verify: (_) {
      verify(() => repository.registrarSubponto('pa1', any())).called(2);
    },
  );
}
