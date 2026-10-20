import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/geoprag_modules.dart';

void main() {
  const usuarioJson = {
    'id': 'u-0001',
    'nome': 'Fulano de Tal',
    'perfil': 'APLICADOR',
    'tenantId': 'gaspar-sc',
    'email': 'fulano@exemplo.com',
    'status': 'ATIVO',
  };

  group('LoginRequestDto', () {
    test('serializa identificador e senha', () {
      const dto = LoginRequestDto(
        identificador: 'gestor@exemplo.com',
        senha: 'segredo',
      );

      expect(dto.toJson(), {
        'identificador': 'gestor@exemplo.com',
        'senha': 'segredo',
      });
    });

    test('toString não expõe identificador nem senha', () {
      const dto = LoginRequestDto(
        identificador: 'gestor@exemplo.com',
        senha: 'segredo',
      );

      expect(dto.toString(), isNot(contains('segredo')));
      expect(dto.toString(), isNot(contains('gestor@exemplo.com')));
    });
  });

  group('LoginResponseDto.fromJson', () {
    test('lê a resposta do aplicador, com refreshToken', () {
      final dto = LoginResponseDto.fromJson({
        'accessToken': 'eyJ.a',
        'expiresInSeconds': 900,
        'refreshToken': 'r8f',
        'usuario': usuarioJson,
      });

      expect(dto.accessToken, 'eyJ.a');
      expect(dto.expiresInSeconds, 900);
      expect(dto.refreshToken, 'r8f');
      expect(dto.usuario.id, 'u-0001');
      expect(dto.usuario.perfil, PerfilDto.aplicador);
    });

    test('refreshToken é opcional (administrador não recebe)', () {
      final dto = LoginResponseDto.fromJson({
        'accessToken': 'eyJ.a',
        'expiresInSeconds': 900,
        'usuario': {...usuarioJson, 'perfil': 'ADMINISTRADOR'},
      });

      expect(dto.refreshToken, isNull);
      expect(dto.toJson().containsKey('refreshToken'), isFalse);
    });

    test('aceita expiresInSeconds numérico inteiro vindo como double', () {
      final dto = LoginResponseDto.fromJson({
        'accessToken': 'a',
        'expiresInSeconds': 900.0,
        'usuario': usuarioJson,
      });

      expect(dto.expiresInSeconds, 900);
    });

    test('ida e volta: toJson reproduz o JSON do contrato', () {
      final json = {
        'accessToken': 'eyJ.a',
        'expiresInSeconds': 900,
        'refreshToken': 'r8f',
        'usuario': usuarioJson,
      };

      expect(LoginResponseDto.fromJson(json).toJson(), json);
    });

    test('campo obrigatório ausente ou inválido vira FormatException', () {
      expect(
        () => LoginResponseDto.fromJson({
          'expiresInSeconds': 900,
          'usuario': usuarioJson,
        }),
        throwsFormatException,
      );
      expect(
        () => LoginResponseDto.fromJson({
          'accessToken': 'a',
          'expiresInSeconds': '900',
          'usuario': usuarioJson,
        }),
        throwsFormatException,
      );
      expect(
        () => LoginResponseDto.fromJson({
          'accessToken': 'a',
          'expiresInSeconds': 900,
        }),
        throwsFormatException,
      );
      expect(
        () => LoginResponseDto.fromJson({
          'accessToken': 'a',
          'expiresInSeconds': 900,
          'refreshToken': 123,
          'usuario': usuarioJson,
        }),
        throwsFormatException,
      );
    });

    test('toString não expõe tokens', () {
      final dto = LoginResponseDto.fromJson({
        'accessToken': 'token-secreto',
        'expiresInSeconds': 900,
        'refreshToken': 'refresh-secreto',
        'usuario': usuarioJson,
      });

      expect(dto.toString(), isNot(contains('token-secreto')));
      expect(dto.toString(), isNot(contains('refresh-secreto')));
    });
  });

  group('refresh', () {
    test('RefreshRequestDto serializa o refreshToken', () {
      const dto = RefreshRequestDto(refreshToken: 'r8f');

      expect(dto.toJson(), {'refreshToken': 'r8f'});
      expect(dto.toString(), isNot(contains('r8f')));
    });

    test('RefreshResponseDto lê o novo par de tokens', () {
      final dto = RefreshResponseDto.fromJson({
        'accessToken': 'eyJ.b',
        'refreshToken': 'r9a',
      });

      expect(dto.accessToken, 'eyJ.b');
      expect(dto.refreshToken, 'r9a');
      expect(dto.toJson(), {'accessToken': 'eyJ.b', 'refreshToken': 'r9a'});
      expect(dto.toString(), isNot(contains('r9a')));
    });

    test('RefreshResponseDto sem refreshToken vira FormatException', () {
      expect(
        () => RefreshResponseDto.fromJson({'accessToken': 'eyJ.b'}),
        throwsFormatException,
      );
    });
  });
}
