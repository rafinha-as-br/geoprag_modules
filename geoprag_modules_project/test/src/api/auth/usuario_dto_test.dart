import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/geoprag_modules.dart';

void main() {
  const jsonAplicador = {
    'id': 'u-0001',
    'nome': 'Fulano de Tal',
    'perfil': 'APLICADOR',
    'tenantId': 'gaspar-sc',
    'email': 'fulano@exemplo.com',
    'status': 'ATIVO',
  };

  group('UsuarioDto.fromJson', () {
    test('lê o usuario do contrato v0', () {
      final dto = UsuarioDto.fromJson(jsonAplicador);

      expect(dto.id, 'u-0001');
      expect(dto.nome, 'Fulano de Tal');
      expect(dto.perfil, PerfilDto.aplicador);
      expect(dto.tenantId, 'gaspar-sc');
      expect(dto.email, 'fulano@exemplo.com');
      expect(dto.status, StatusUsuarioDto.ativo);
    });

    test('aceita os três perfis e os dois status', () {
      for (final (valor, perfil) in [
        ('ADMINISTRADOR', PerfilDto.administrador),
        ('SUB_ADMINISTRADOR', PerfilDto.subAdministrador),
        ('APLICADOR', PerfilDto.aplicador),
      ]) {
        expect(
          UsuarioDto.fromJson({...jsonAplicador, 'perfil': valor}).perfil,
          perfil,
        );
      }
      expect(
        UsuarioDto.fromJson({...jsonAplicador, 'status': 'DESATIVADO'}).status,
        StatusUsuarioDto.desativado,
      );
    });

    test('ida e volta: toJson reproduz o JSON do contrato', () {
      expect(UsuarioDto.fromJson(jsonAplicador).toJson(), jsonAplicador);
    });

    test('campo ausente, vazio ou de tipo errado vira FormatException', () {
      for (final campo in jsonAplicador.keys) {
        final semCampo = {...jsonAplicador}..remove(campo);
        expect(
          () => UsuarioDto.fromJson(semCampo),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('"$campo"'),
            ),
          ),
          reason: 'sem $campo',
        );
      }
      expect(
        () => UsuarioDto.fromJson({...jsonAplicador, 'id': 42}),
        throwsFormatException,
      );
      expect(
        () => UsuarioDto.fromJson({...jsonAplicador, 'nome': ''}),
        throwsFormatException,
      );
    });

    test('perfil e status desconhecidos viram FormatException', () {
      expect(
        () => UsuarioDto.fromJson({...jsonAplicador, 'perfil': 'ROOT'}),
        throwsFormatException,
      );
      expect(
        () => UsuarioDto.fromJson({...jsonAplicador, 'status': 'SUSPENSO'}),
        throwsFormatException,
      );
    });

    test('campos extras do servidor são ignorados', () {
      final dto = UsuarioDto.fromJson({...jsonAplicador, 'novo': true});

      expect(dto.id, 'u-0001');
    });

    test('igualdade por valor', () {
      expect(
        UsuarioDto.fromJson(jsonAplicador),
        UsuarioDto.fromJson({...jsonAplicador}),
      );
      expect(
        UsuarioDto.fromJson(jsonAplicador),
        isNot(UsuarioDto.fromJson({...jsonAplicador, 'id': 'u-0002'})),
      );
    });
  });
}
