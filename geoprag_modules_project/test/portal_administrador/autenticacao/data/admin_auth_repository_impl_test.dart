import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_auth_exceptions.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/data/admin_auth_repository_impl.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/data/mock_admin_accounts.dart';
import 'package:geoprag_modules/src/api/api_client.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:geoprag_modules/src/api/auth/usuario_dto.dart';
import 'package:geoprag_modules/src/api/sessao_segura.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/armazenamento_em_memoria.dart';
import '../../../support/login_fixtures.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient api;
  late ArmazenamentoEmMemoria armazenamento;
  late SessaoSegura sessao;
  late AdminAuthRepositoryImpl repository;
  var agora = DateTime.utc(2026, 10, 20, 12);

  void respondeLogin(Map<String, dynamic> corpo) => when(
    () => api.post(
      any(),
      corpo: any(named: 'corpo'),
      autenticado: any(named: 'autenticado'),
    ),
  ).thenAnswer((_) async => corpo);

  // O portal não recebe refresh token.
  Map<String, dynamic> loginAdmin({
    PerfilDto perfil = PerfilDto.administrador,
    int expiresInSeconds = 900,
  }) => respostaDeLogin(
    perfil: perfil,
    refreshToken: null,
    expiresInSeconds: expiresInSeconds,
  );

  setUp(() {
    api = MockApiClient();
    armazenamento = ArmazenamentoEmMemoria();
    sessao = SessaoSegura(armazenamento: armazenamento);
    agora = DateTime.utc(2026, 10, 20, 12);
    repository = AdminAuthRepositoryImpl(
      api: api,
      sessao: sessao,
      agora: () => agora,
    );
  });

  group('login', () {
    test(
      'chama POST /auth/login sem token, com o identificador sem espaços',
      () async {
        respondeLogin(loginAdmin());

        await repository.login(
          identifier: '  admin@gaspar.sc.gov.br ',
          senha: 'abc12345',
        );

        verify(
          () => api.post(
            '/auth/login',
            corpo: {
              'identificador': 'admin@gaspar.sc.gov.br',
              'senha': 'abc12345',
            },
            autenticado: false,
          ),
        ).called(1);
      },
    );

    test(
      'devolve a conta com id, tenantId e cargo do servidor e guarda a sessão',
      () async {
        respondeLogin(loginAdmin(perfil: PerfilDto.subAdministrador));

        final conta = await repository.login(identifier: 'x', senha: 'y');

        expect(conta.id, 'u-0001');
        expect(conta.tenantId, 'gaspar-sc');
        expect(conta.role, AdminRole.subAdministrador);
        expect(await sessao.accessToken(), 'access-1');
        expect(await sessao.refreshToken(), isNull);
      },
    );

    test('recusa conta de aplicador e não guarda nada', () async {
      respondeLogin(respostaDeLogin());

      await expectLater(
        repository.login(identifier: 'x', senha: 'y'),
        throwsA(isA<InvalidCredentialsException>()),
      );
      expect(armazenamento.dados, isEmpty);
    });

    test(
      'credenciais recusadas pelo servidor propagam a mensagem dele',
      () async {
        when(
          () => api.post(
            any(),
            corpo: any(named: 'corpo'),
            autenticado: any(named: 'autenticado'),
          ),
        ).thenThrow(const AcessoNegadoException('Usuário desativado'));

        await expectLater(
          repository.login(identifier: 'x', senha: 'y'),
          throwsA(
            isA<AcessoNegadoException>().having(
              (e) => e.mensagemAmigavel,
              'mensagem',
              'Usuário desativado',
            ),
          ),
        );
        expect(armazenamento.dados, isEmpty);
      },
    );
  });

  group('sessaoAtual', () {
    test('sem sessão guardada devolve null', () async {
      expect(await repository.sessaoAtual(), isNull);
    });

    test(
      'reabre a sessão enquanto o access token está dentro da validade',
      () async {
        respondeLogin(loginAdmin());
        await repository.login(identifier: 'x', senha: 'y');
        agora = agora.add(const Duration(minutes: 10));

        final conta = await repository.sessaoAtual();

        expect(conta!.id, 'u-0001');
        expect(conta.role, AdminRole.administrador);
      },
    );

    test('access token vencido (ou quase) encerra a sessão guardada', () async {
      respondeLogin(loginAdmin());
      await repository.login(identifier: 'x', senha: 'y');
      agora = agora.add(const Duration(seconds: 890));

      expect(await repository.sessaoAtual(), isNull);
      expect(armazenamento.dados, isEmpty);
    });
  });

  test('logout apaga token e conta do navegador', () async {
    respondeLogin(loginAdmin());
    await repository.login(identifier: 'x', senha: 'y');

    await repository.logout();

    expect(armazenamento.dados, isEmpty);
    expect(await repository.sessaoAtual(), isNull);
  });

  group('findByEmail (sem endpoint no contrato v0)', () {
    test(
      'retorna a conta correspondente ao e-mail (case-insensitive)',
      () async {
        final account = mockAdminAccounts.firstWhere(
          (a) => a.role == AdminRole.subAdministrador,
        );

        final result = await repository.findByEmail(
          account.email.toUpperCase(),
        );

        expect(result, isNotNull);
        expect(result!.role, AdminRole.subAdministrador);
      },
    );

    test(
      'retorna null quando o e-mail não existe em mockAdminAccounts',
      () async {
        final result = await repository.findByEmail('ninguem@gaspar.sc.gov.br');
        expect(result, isNull);
      },
    );
  });

  group('demais operações simuladas', () {
    test('resetPassword completa sem lançar exceção', () async {
      await expectLater(
        repository.resetPassword(novaSenha: 'nova-senha-123'),
        completes,
      );
    });
  });
}
