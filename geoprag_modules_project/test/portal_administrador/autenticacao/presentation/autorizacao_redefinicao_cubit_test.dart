import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/solicitacao_redefinicao.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/solicitacao_redefinicao_repository.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/autorizacao_redefinicao_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/autorizacao_redefinicao_state.dart';
import 'package:mocktail/mocktail.dart';

class MockSolicitacaoRedefinicaoRepository extends Mock
    implements SolicitacaoRedefinicaoRepository {}

void main() {
  late MockSolicitacaoRedefinicaoRepository repository;

  const pendente = SolicitacaoRedefinicao(
    id: 'sr1',
    nomeSolicitante: 'Célia Ramos',
    cargo: 'Sub-Administrador',
    status: StatusSolicitacaoRedefinicao.aguardando,
  );

  setUp(() {
    repository = MockSolicitacaoRedefinicaoRepository();
  });

  blocTest<AutorizacaoRedefinicaoCubit, AutorizacaoRedefinicaoState>(
    'emite [Loaded] com a solicitação pendente mapeada para ViewModel',
    setUp: () {
      when(() => repository.buscarPendente()).thenAnswer((_) async => pendente);
    },
    build: () => AutorizacaoRedefinicaoCubit(repository),
    expect: () => [
      isA<AutorizacaoRedefinicaoLoaded>().having(
        (s) => s.solicitacao.status,
        'solicitacao.status',
        StatusSolicitacaoRedefinicao.aguardando,
      ),
    ],
  );

  blocTest<AutorizacaoRedefinicaoCubit, AutorizacaoRedefinicaoState>(
    'emite [Error] com mensagem amigável quando buscarPendente falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.buscarPendente()).thenThrow(Exception('offline'));
    },
    build: () => AutorizacaoRedefinicaoCubit(repository),
    expect: () => [
      isA<AutorizacaoRedefinicaoError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );

  blocTest<AutorizacaoRedefinicaoCubit, AutorizacaoRedefinicaoState>(
    'autorizar() chama o repositório com o id carregado e emite [Loaded] atualizado',
    setUp: () {
      when(() => repository.buscarPendente()).thenAnswer((_) async => pendente);
      when(() => repository.autorizar('sr1')).thenAnswer(
        (_) async =>
            pendente.copyWith(status: StatusSolicitacaoRedefinicao.autorizado),
      );
    },
    build: () => AutorizacaoRedefinicaoCubit(repository),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      await cubit.autorizar();
    },
    expect: () => [
      isA<AutorizacaoRedefinicaoLoaded>().having(
        (s) => s.solicitacao.status,
        'solicitacao.status',
        StatusSolicitacaoRedefinicao.aguardando,
      ),
      isA<AutorizacaoRedefinicaoLoaded>().having(
        (s) => s.solicitacao.status,
        'solicitacao.status',
        StatusSolicitacaoRedefinicao.autorizado,
      ),
    ],
    verify: (_) {
      verify(() => repository.autorizar('sr1')).called(1);
    },
  );

  blocTest<AutorizacaoRedefinicaoCubit, AutorizacaoRedefinicaoState>(
    'negar() chama o repositório com o id carregado e emite [Loaded] atualizado',
    setUp: () {
      when(() => repository.buscarPendente()).thenAnswer((_) async => pendente);
      when(() => repository.negar('sr1')).thenAnswer(
        (_) async =>
            pendente.copyWith(status: StatusSolicitacaoRedefinicao.negado),
      );
    },
    build: () => AutorizacaoRedefinicaoCubit(repository),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      await cubit.negar();
    },
    expect: () => [
      isA<AutorizacaoRedefinicaoLoaded>().having(
        (s) => s.solicitacao.status,
        'solicitacao.status',
        StatusSolicitacaoRedefinicao.aguardando,
      ),
      isA<AutorizacaoRedefinicaoLoaded>().having(
        (s) => s.solicitacao.status,
        'solicitacao.status',
        StatusSolicitacaoRedefinicao.negado,
      ),
    ],
    verify: (_) {
      verify(() => repository.negar('sr1')).called(1);
    },
  );
}
