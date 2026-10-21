import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/aplicador_resumo_repository_http.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/bairro_repository_http.dart';
import 'package:geoprag_modules/src/api/api_client.dart';
import 'package:geoprag_modules/src/api/api_exceptions.dart';
import 'package:geoprag_modules/src/entities/usuario.dart';
import 'package:mocktail/mocktail.dart';

class _ApiFalsa extends Mock implements ApiClient {}

void main() {
  late _ApiFalsa api;

  setUp(() => api = _ApiFalsa());

  group('AplicadorResumoRepositoryHttp', () {
    test('lê GET /aplicadores com nome e status', () async {
      when(() => api.get('/aplicadores')).thenAnswer(
        (_) async => [
          {'id': 'ap-3', 'nome': 'Aplicador Exemplo Um', 'status': 'ATIVO'},
          {
            'id': 'ap-5',
            'nome': 'Aplicador Exemplo Desativado',
            'status': 'DESATIVADO',
          },
        ],
      );

      final aplicadores = await AplicadorResumoRepositoryHttp(api).listar();

      expect(aplicadores.map((a) => a.nome), [
        'Aplicador Exemplo Um',
        'Aplicador Exemplo Desativado',
      ]);
      expect(aplicadores.first.status, UsuarioStatus.ativo);
      expect(aplicadores.first.ativo, isTrue);
      expect(aplicadores.last.status, UsuarioStatus.desativado);
      expect(aplicadores.last.ativo, isFalse);
    });

    test('status desconhecido é recusado', () async {
      when(() => api.get('/aplicadores')).thenAnswer(
        (_) async => [
          {'id': 'ap-3', 'nome': 'X', 'status': 'SUSPENSO'},
        ],
      );

      await expectLater(
        AplicadorResumoRepositoryHttp(api).listar(),
        throwsFormatException,
      );
    });

    test('resposta que não é lista é recusada', () async {
      when(() => api.get('/aplicadores')).thenAnswer((_) async => 'oi');

      await expectLater(
        AplicadorResumoRepositoryHttp(api).listar(),
        throwsFormatException,
      );
    });

    test('acesso negado (403) chega como AcessoNegadoException', () async {
      when(
        () => api.get('/aplicadores'),
      ).thenThrow(const AcessoNegadoException('Você não tem permissão.'));

      await expectLater(
        AplicadorResumoRepositoryHttp(api).listar(),
        throwsA(isA<AcessoNegadoException>()),
      );
    });
  });

  group('BairroRepositoryHttp', () {
    test('lê GET /bairros', () async {
      when(() => api.get('/bairros')).thenAnswer(
        (_) async => [
          {'id': 'b-2', 'nome': 'Bela Vista'},
          {'id': 'b-1', 'nome': 'Centro'},
        ],
      );

      final bairros = await BairroRepositoryHttp(api).listar();

      expect(bairros.map((b) => (b.id, b.nome)), [
        ('b-2', 'Bela Vista'),
        ('b-1', 'Centro'),
      ]);
    });

    test('lista vazia é uma lista vazia', () async {
      when(() => api.get('/bairros')).thenAnswer((_) async => <Object?>[]);

      expect(await BairroRepositoryHttp(api).listar(), isEmpty);
    });

    test('resposta que não é lista é recusada', () async {
      when(() => api.get('/bairros')).thenAnswer((_) async => null);

      await expectLater(
        BairroRepositoryHttp(api).listar(),
        throwsFormatException,
      );
    });
  });
}
