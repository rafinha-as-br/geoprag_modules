import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'api_config.dart';
import 'sessao_segura.dart';

/// Instância única do [ApiClient] do processo.
///
/// Os `Bootstrap` dos dois apps pedem o cliente aqui, então todos os
/// repositórios compartilham a mesma sessão e a mesma renovação de token. A
/// instância é criada na primeira vez que alguém a usa — um app que só roda com
/// mocks, sem `API_BASE_URL`, nunca chega a construí-la.
class ApiClientProvider {
  const ApiClientProvider._();

  static ApiClient? _instancia;
  static SessaoSegura? _sessao;

  /// Chamado quando o refresh token é recusado ou ausente e a sessão acabou
  /// (os tokens já foram apagados). O app liga isto ao encerramento da sessão
  /// no roteador, antes do primeiro uso do cliente.
  static void Function()? aoPerderSessao;

  /// Sessão persistente (GEOPRAG-187), compartilhada pelo cliente HTTP e pelos
  /// repositórios de autenticação.
  static SessaoSegura get sessao => _sessao ??= SessaoSegura();

  static ApiClient get instancia => _instancia ??= ApiClient(
    config: ApiConfig.doAmbiente(),
    sessao: sessao,
    aoPerderSessao: () => aoPerderSessao?.call(),
  );

  /// Substitui a sessão persistente (ex.: nos testes dos apps, por uma sobre
  /// armazenamento em memória). Chamar antes do primeiro uso do cliente.
  @visibleForTesting
  static void configurarSessao(SessaoSegura sessao) => _sessao = sessao;

  /// Substitui a instância (ex.: em testes, ou com outra configuração). Chamar
  /// antes do primeiro uso. Os repositórios de autenticação gravam o login em
  /// [sessao]: um cliente com outra sessão precisa vir junto de
  /// [configurarSessao] com a mesma, senão o login e o `Authorization` divergem.
  static void configurar(ApiClient cliente) => _instancia = cliente;

  @visibleForTesting
  static void redefinir() {
    _instancia = null;
    _sessao = null;
    aoPerderSessao = null;
  }
}
