import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/pontos_de_aplicacao_cubit.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/pontos_de_aplicacao_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminPontoDeAplicacaoRepository extends Mock
    implements AdminPontoDeAplicacaoRepository {}

void main() {
  late MockAdminPontoDeAplicacaoRepository repository;

  final pontos = [
    const AdminPontoDeAplicacao(
      id: '1',
      bairro: 'Belchior',
      lat: -26.99,
      lng: -48.95,
      status: StatusPontoDeAplicacao.feita,
    ),
    const AdminPontoDeAplicacao(
      id: '2',
      bairro: 'Poço Grande',
      lat: -26.98,
      lng: -48.94,
      status: StatusPontoDeAplicacao.planejada,
    ),
    const AdminPontoDeAplicacao(
      id: '3',
      bairro: 'Belchior',
      lat: -26.97,
      lng: -48.93,
      status: StatusPontoDeAplicacao.feita,
      ativo: false,
    ),
  ];

  setUp(() {
    repository = MockAdminPontoDeAplicacaoRepository();
    when(() => repository.listar()).thenAnswer((_) async => pontos);
  });

  blocTest<PontosDeAplicacaoCubit, PontosDeAplicacaoState>(
    'sem filtro de bairro: emite [Loaded] só com os pontos ativos, de todos os bairros',
    build: () => PontosDeAplicacaoCubit(repository),
    expect: () => [
      isA<PontosDeAplicacaoLoaded>().having(
        (s) => s.pontos.map((p) => p.id),
        'pontos.ids',
        containsAll(['1', '2']),
      ),
    ],
    verify: (cubit) {
      final state = cubit.state as PontosDeAplicacaoLoaded;
      expect(state.pontos, hasLength(2));
      expect(state.pontos.any((p) => p.id == '3'), isFalse);
    },
  );

  blocTest<PontosDeAplicacaoCubit, PontosDeAplicacaoState>(
    'com bairro informado: emite [Loaded] só com os pontos ativos daquele bairro',
    build: () => PontosDeAplicacaoCubit(repository, bairro: 'Belchior'),
    verify: (cubit) {
      final state = cubit.state as PontosDeAplicacaoLoaded;
      expect(state.pontos, hasLength(1));
      expect(state.pontos.single.id, '1');
    },
  );

  blocTest<PontosDeAplicacaoCubit, PontosDeAplicacaoState>(
    'emite [Error] com mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.listar()).thenThrow(Exception('offline'));
    },
    build: () => PontosDeAplicacaoCubit(repository),
    expect: () => [
      isA<PontosDeAplicacaoError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
