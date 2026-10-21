import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/api/api_client.dart';
import 'package:geoprag_modules/src/api/api_client_provider.dart';
import 'package:geoprag_modules/src/api/api_config.dart';
import 'package:geoprag_modules/src/api/sessao_de_tokens.dart';
import 'package:geoprag_modules/src/api/sessao_segura.dart';

import '../../support/armazenamento_em_memoria.dart';

void main() {
  setUp(ApiClientProvider.redefinir);
  tearDown(ApiClientProvider.redefinir);

  test('a sessão persistente é única e a mesma em todas as consultas', () {
    expect(
      identical(ApiClientProvider.sessao, ApiClientProvider.sessao),
      isTrue,
    );
  });

  test('configurarSessao troca a sessão usada pelos repositórios', () {
    final emMemoria = SessaoSegura(armazenamento: ArmazenamentoEmMemoria());

    ApiClientProvider.configurarSessao(emMemoria);

    expect(identical(ApiClientProvider.sessao, emMemoria), isTrue);
  });

  test('configurar substitui o cliente sem exigir API_BASE_URL', () {
    final cliente = ApiClient(
      config: ApiConfig(baseUrl: 'http://localhost:8080'),
      sessao: SessaoDeTokensEmMemoria(),
    );

    ApiClientProvider.configurar(cliente);

    expect(identical(ApiClientProvider.instancia, cliente), isTrue);
  });

  test(
    'sem API_BASE_URL e sem cliente configurado, o primeiro uso falha alto',
    () {
      expect(() => ApiClientProvider.instancia, throwsStateError);
    },
  );

  test('redefinir limpa cliente, sessão e o aviso de sessão perdida', () {
    ApiClientProvider.aoPerderSessao = () {};
    final antes = ApiClientProvider.sessao;

    ApiClientProvider.redefinir();

    expect(ApiClientProvider.aoPerderSessao, isNull);
    expect(identical(ApiClientProvider.sessao, antes), isFalse);
  });
}
