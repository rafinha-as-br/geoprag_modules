import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/data/mock_admin_accounts.dart';
import 'package:geoprag_modules/portal_administrador/bootstrap.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/admin_ponto_de_aplicacao_repository_http.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/aplicador_resumo_repository_http.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/data/bairro_repository_http.dart';
import 'package:geoprag_modules/src/api/api_client.dart';
import 'package:geoprag_modules/src/api/api_client_provider.dart';
import 'package:geoprag_modules/src/api/api_config.dart';
import 'package:geoprag_modules/src/api/sessao_de_tokens.dart';

void main() {
  const bootstrap = AdminBootstrap();
  final conta = mockAdminAccounts.first;

  setUp(() {
    ApiClientProvider.redefinir();
    ApiClientProvider.configurar(
      ApiClient(
        config: ApiConfig(baseUrl: 'http://localhost:8080'),
        sessao: SessaoDeTokensEmMemoria(),
      ),
    );
  });

  tearDown(ApiClientProvider.redefinir);

  test('a Gestão de Aplicações usa os repositórios HTTP, não os mocks', () {
    expect(
      bootstrap.buildAdminPontoDeAplicacaoRepository(contaAtual: conta),
      isA<AdminPontoDeAplicacaoRepositoryHttp>(),
    );
    expect(
      bootstrap.buildAplicadorResumoRepository(),
      isA<AplicadorResumoRepositoryHttp>(),
    );
    expect(bootstrap.buildBairroRepository(), isA<BairroRepositoryHttp>());
  });

  test(
    'os cubits da Gestão de Aplicações montam sobre os repositórios HTTP',
    () async {
      final dashboard = bootstrap.buildPontosDeAplicacaoCubit(
        contaAtual: conta,
      );
      final bairro = bootstrap.buildPontosDoBairroCubit(
        'Centro',
        contaAtual: conta,
      );
      final detalhe = bootstrap.buildPontoDeAplicacaoDetalheCubit(
        'p-1',
        contaAtual: conta,
      );
      // Sem servidor no teste, os três terminam em erro amigável; o que importa
      // aqui é que montaram e não usam mais dados fixos.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(dashboard.state.items, isEmpty);
      expect(bairro.state.items, isEmpty);
      await dashboard.close();
      await bairro.close();
      await detalhe.close();
    },
  );
}
