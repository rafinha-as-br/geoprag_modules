import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_state.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/permissions/capacidade.dart';

void main() {
  final conta = AdminAccount(
    email: 'admin@gaspar.sc.gov.br',
    nome: 'Marcos Vieira',
    cpf: '123.456.789-00',
    dataNascimento: DateTime(1980, 5, 12),
    sexo: 'Masculino',
    dataCriacao: DateTime(2026, 1, 1),
    role: AdminRole.administrador,
  );

  blocTest<AdminSessionCubit, AdminSessionState>(
    'estado inicial é SemAcesso',
    build: () => AdminSessionCubit(),
    verify: (cubit) => expect(cubit.state, isA<AdminSessionSemAcesso>()),
  );

  blocTest<AdminSessionCubit, AdminSessionState>(
    'iniciarSessao emite Autenticado com a conta informada',
    build: () => AdminSessionCubit(),
    act: (cubit) => cubit.iniciarSessao(conta),
    expect: () => [
      isA<AdminSessionAutenticado>().having(
        (s) => s.conta.role,
        'conta.role',
        AdminRole.administrador,
      ),
    ],
  );

  blocTest<AdminSessionCubit, AdminSessionState>(
    'encerrarSessao emite SemAcesso novamente',
    build: () => AdminSessionCubit(),
    seed: () => AdminSessionAutenticado(conta),
    act: (cubit) => cubit.encerrarSessao(),
    expect: () => [isA<AdminSessionSemAcesso>()],
  );

  group('podeExecutar (GEOPRAG-112)', () {
    test('sem sessão autenticada, nunca libera nenhuma capacidade', () {
      final cubit = AdminSessionCubit();
      expect(cubit.podeExecutar(Capacidade.ativarPontoAplicacao), isFalse);
    });

    test('Administrador autenticado libera as capacidades do módulo', () {
      final cubit = AdminSessionCubit()..iniciarSessao(conta);
      expect(cubit.podeExecutar(Capacidade.criarPontoAplicacao), isTrue);
      expect(cubit.podeExecutar(Capacidade.ativarPontoAplicacao), isTrue);
    });

    test('Sub-Administrador tem paridade total com Administrador hoje', () {
      final subConta = conta.copyWith(role: AdminRole.subAdministrador);
      final cubit = AdminSessionCubit()..iniciarSessao(subConta);
      for (final capacidade in Capacidade.values) {
        expect(cubit.podeExecutar(capacidade), isTrue);
      }
    });
  });

  group('garantirCapacidade (GEOPRAG-112)', () {
    test('não lança quando a sessão tem a capacidade', () {
      final cubit = AdminSessionCubit()..iniciarSessao(conta);
      expect(
        () => cubit.garantirCapacidade(Capacidade.desativarPontoAplicacao),
        returnsNormally,
      );
    });

    test('lança OperacaoNaoPermitidaException sem sessão autenticada', () {
      final cubit = AdminSessionCubit();
      expect(
        () => cubit.garantirCapacidade(Capacidade.desativarPontoAplicacao),
        throwsA(isA<OperacaoNaoPermitidaException>()),
      );
    });
  });
}
