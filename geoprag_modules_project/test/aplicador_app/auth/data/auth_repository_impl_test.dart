import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/auth/core/auth_exceptions.dart';
import 'package:geoprag_modules/aplicador_app/auth/data/auth_repository_impl.dart';
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
  late AuthRepositoryImpl repository;
  var agora = DateTime.utc(2026, 10, 20, 12);

  void respondeLogin(Map<String, dynamic> corpo) => when(
    () => api.post(
      any(),
      corpo: any(named: 'corpo'),
      autenticado: any(named: 'autenticado'),
    ),
  ).thenAnswer((_) async => corpo);

  setUp(() {
    api = MockApiClient();
    armazenamento = ArmazenamentoEmMemoria();
    sessao = SessaoSegura(armazenamento: armazenamento);
    agora = DateTime.utc(2026, 10, 20, 12);
    repository = AuthRepositoryImpl(
      api: api,
      sessao: sessao,
      agora: () => agora,
    );
  });

  group('login', () {
    test(
      'chama POST /auth/login sem token, com o identificador sem espaços',
      () async {
        respondeLogin(respostaDeLogin());

        await repository.login(
          identifier: '  123.456.789-00 ',
          senha: 'abc12345',
        );

        verify(
          () => api.post(
            '/auth/login',
            corpo: {'identificador': '123.456.789-00', 'senha': 'abc12345'},
            autenticado: false,
          ),
        ).called(1);
      },
    );

    test(
      'devolve o usuário com id e tenantId do servidor e guarda a sessão',
      () async {
        respondeLogin(respostaDeLogin(id: 'u-77', tenantId: 'outra-cidade'));

        final usuario = await repository.login(identifier: 'x', senha: 'y');

        expect(usuario.id, 'u-77');
        expect(usuario.tenantId, 'outra-cidade');
        expect(await sessao.accessToken(), 'access-1');
        expect(await sessao.refreshToken(), 'refresh-1');
      },
    );

    test('recusa conta de administrador e não guarda nada', () async {
      respondeLogin(respostaDeLogin(perfil: PerfilDto.administrador));

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
        ).thenThrow(const NaoAutenticadoException('Credenciais inválidas'));

        await expectLater(
          repository.login(identifier: 'x', senha: 'errada'),
          throwsA(
            isA<NaoAutenticadoException>().having(
              (e) => e.mensagemAmigavel,
              'mensagem',
              'Credenciais inválidas',
            ),
          ),
        );
        expect(armazenamento.dados, isEmpty);
      },
    );

    test('resposta fora do formato não guarda sessão', () async {
      respondeLogin({'accessToken': 'so-isso'});

      await expectLater(
        repository.login(identifier: 'x', senha: 'y'),
        throwsA(isA<FormatException>()),
      );
      expect(armazenamento.dados, isEmpty);
    });
  });

  group('sessaoAtual', () {
    test('sem sessão guardada devolve null', () async {
      expect(await repository.sessaoAtual(), isNull);
    });

    test(
      'reabre a sessão sem chamar a rede, mesmo com o access token vencido',
      () async {
        respondeLogin(respostaDeLogin(id: 'u-77', expiresInSeconds: 60));
        await repository.login(identifier: 'x', senha: 'y');
        clearInteractions(api);
        agora = agora.add(const Duration(days: 10));

        final usuario = await repository.sessaoAtual();

        expect(usuario!.id, 'u-77');
        expect(usuario.tenantId, 'gaspar-sc');
        verifyZeroInteractions(api);
      },
    );

    test(
      'sessão sem refresh token não sustenta o aplicador e é apagada',
      () async {
        respondeLogin(respostaDeLogin(refreshToken: null));
        await repository.login(identifier: 'x', senha: 'y');

        expect(await repository.sessaoAtual(), isNull);
        expect(armazenamento.dados, isEmpty);
      },
    );

    test('sessão de outro perfil guardada no aparelho é apagada', () async {
      respondeLogin(respostaDeLogin());
      await repository.login(identifier: 'x', senha: 'y');
      await armazenamento.gravar(
        'geoprag.sessao.usuario',
        '{"id":"a","nome":"A","perfil":"ADMINISTRADOR","tenantId":"t",'
            '"email":"a@a","status":"ATIVO"}',
      );

      expect(await repository.sessaoAtual(), isNull);
      expect(armazenamento.dados, isEmpty);
    });
  });

  test('logout apaga tokens e usuário do aparelho', () async {
    respondeLogin(respostaDeLogin());
    await repository.login(identifier: 'x', senha: 'y');

    await repository.logout();

    expect(armazenamento.dados, isEmpty);
    expect(await repository.sessaoAtual(), isNull);
  });

  group('recuperação de senha (sem endpoint no contrato v0)', () {
    test('requestPasswordReset completa sem lançar exceção', () async {
      await expectLater(
        repository.requestPasswordReset(email: 'aplicador@example.com'),
        completes,
      );
    });

    test('verifyResetCode completa sem lançar exceção', () async {
      await expectLater(repository.verifyResetCode(code: '123456'), completes);
    });

    test('resetPassword completa sem lançar exceção', () async {
      await expectLater(
        repository.resetPassword(novaSenha: 'nova-senha-123'),
        completes,
      );
    });
  });
}
