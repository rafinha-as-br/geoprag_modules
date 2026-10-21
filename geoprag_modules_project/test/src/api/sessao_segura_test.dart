import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/api/auth/login_dtos.dart';
import 'package:geoprag_modules/src/api/auth/usuario_dto.dart';
import 'package:geoprag_modules/src/api/sessao_segura.dart';

import '../../support/armazenamento_em_memoria.dart';
import '../../support/login_fixtures.dart';

void main() {
  late ArmazenamentoEmMemoria armazenamento;
  late SessaoSegura sessao;
  final agora = DateTime.utc(2026, 10, 20, 12);

  LoginResponseDto login({
    PerfilDto perfil = PerfilDto.aplicador,
    String? refreshToken = 'refresh-1',
  }) => LoginResponseDto.fromJson(
    respostaDeLogin(perfil: perfil, refreshToken: refreshToken),
  );

  setUp(() {
    armazenamento = ArmazenamentoEmMemoria();
    sessao = SessaoSegura(armazenamento: armazenamento);
  });

  test('sem nada guardado não há sessão para restaurar', () async {
    expect(await sessao.restaurar(), isNull);
    expect(await sessao.accessToken(), isNull);
  });

  test('iniciar guarda tokens e usuário, e restaurar os devolve', () async {
    await sessao.iniciar(login(), agora: agora);

    expect(await sessao.accessToken(), 'access-1');
    expect(await sessao.refreshToken(), 'refresh-1');
    final salva = await sessao.restaurar();
    expect(salva, isNotNull);
    expect(salva!.usuario.id, 'u-0001');
    expect(salva.usuario.tenantId, 'gaspar-sc');
    expect(salva.temRefreshToken, isTrue);
    expect(salva.accessTokenExpiraEm, agora.add(const Duration(seconds: 900)));
  });

  test('sem refresh token (portal), a sessão não tem refresh', () async {
    await sessao.iniciar(
      login(perfil: PerfilDto.administrador, refreshToken: null),
      agora: agora,
    );

    final salva = await sessao.restaurar();
    expect(salva!.temRefreshToken, isFalse);
    expect(await sessao.refreshToken(), isNull);
  });

  test('um novo login substitui a sessão anterior por completo', () async {
    await sessao.iniciar(login(), agora: agora);
    await sessao.iniciar(
      login(perfil: PerfilDto.administrador, refreshToken: null),
      agora: agora,
    );

    expect(await sessao.refreshToken(), isNull);
  });

  test(
    'salvar atualiza o access e só troca o refresh quando informado',
    () async {
      await sessao.iniciar(login(), agora: agora);

      await sessao.salvar(accessToken: 'access-2');
      expect(await sessao.accessToken(), 'access-2');
      expect(await sessao.refreshToken(), 'refresh-1');

      await sessao.salvar(accessToken: 'access-3', refreshToken: 'refresh-2');
      expect(await sessao.refreshToken(), 'refresh-2');
    },
  );

  test('limpar apaga tokens, validade e usuário', () async {
    await sessao.iniciar(login(), agora: agora);

    await sessao.limpar();

    expect(armazenamento.dados, isEmpty);
    expect(await sessao.restaurar(), isNull);
  });

  test(
    'usuário guardado sem access token é sessão incompleta e é apagada',
    () async {
      await sessao.iniciar(login(), agora: agora);
      await armazenamento.apagar('geoprag.sessao.access_token');

      expect(await sessao.restaurar(), isNull);
      expect(armazenamento.dados, isEmpty);
    },
  );

  test('usuário guardado ilegível é descartado em vez de quebrar', () async {
    await sessao.iniciar(login(), agora: agora);
    await armazenamento.gravar('geoprag.sessao.usuario', '{não é json');

    expect(await sessao.restaurar(), isNull);
    expect(armazenamento.dados, isEmpty);
  });

  group('SessaoSalva.accessTokenExpirado', () {
    final salva = SessaoSalva(
      usuario: UsuarioDto.fromJson(
        respostaDeLogin()['usuario'] as Map<String, dynamic>,
      ),
      temRefreshToken: false,
      accessTokenExpiraEm: agora,
    );

    test('é falso antes da validade e verdadeiro a partir dela', () {
      expect(
        salva.accessTokenExpirado(agora.subtract(const Duration(seconds: 1))),
        isFalse,
      );
      expect(salva.accessTokenExpirado(agora), isTrue);
    });

    test('a margem antecipa a expiração', () {
      expect(
        salva.accessTokenExpirado(
          agora.subtract(const Duration(seconds: 10)),
          margem: const Duration(seconds: 30),
        ),
        isTrue,
      );
    });

    test('validade desconhecida nunca conta como expirada', () {
      final semValidade = SessaoSalva(
        usuario: salva.usuario,
        temRefreshToken: false,
      );
      expect(semValidade.accessTokenExpirado(agora), isFalse);
    });
  });
}
