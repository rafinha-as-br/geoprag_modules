import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'api_config.dart';
import 'sessao_de_tokens.dart';

/// Instância única do [ApiClient] do processo.
///
/// Os `Bootstrap` dos dois apps pedem o cliente aqui, então todos os
/// repositórios compartilham a mesma sessão e a mesma renovação de token. A
/// instância é criada na primeira vez que alguém a usa — um app que só roda com
/// mocks, sem `API_BASE_URL`, nunca chega a construí-la.
class ApiClientProvider {
  const ApiClientProvider._();

  static ApiClient? _instancia;

  static ApiClient get instancia => _instancia ??= ApiClient(
    config: ApiConfig.doAmbiente(),
    sessao: SessaoDeTokensEmMemoria(),
  );

  /// Substitui a instância (ex.: com a sessão persistente da GEOPRAG-187, ou
  /// com `aoPerderSessao` ligado ao roteador). Chamar antes do primeiro uso.
  static void configurar(ApiClient cliente) => _instancia = cliente;

  @visibleForTesting
  static void redefinir() => _instancia = null;
}
