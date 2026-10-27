import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/api/auth/login_dtos.dart';

import '../../../support/login_fixtures.dart';

void main() {
  group('LoginResponseDto.fromCorpo', () {
    test('lê o corpo decodificado de POST /auth/login', () {
      final dto = LoginResponseDto.fromCorpo(respostaDeLogin());

      expect(dto.accessToken, 'access-1');
      expect(dto.usuario.id, 'u-0001');
    });

    test('corpo que não é um objeto JSON vira FormatException', () {
      for (final corpo in <Object?>[null, 'texto', <Object?>[]]) {
        expect(
          () => LoginResponseDto.fromCorpo(corpo),
          throwsA(isA<FormatException>()),
        );
      }
    });
  });

  test('a rota de login é pública e fixa', () {
    expect(LoginRequestDto.caminho, '/auth/login');
  });
}
