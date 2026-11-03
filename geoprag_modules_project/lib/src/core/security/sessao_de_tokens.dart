/// Onde o cliente HTTP lê e grava os tokens da sessão.
///
/// É uma interface: o armazenamento seguro em disco (Keychain/Keystore) é da
/// GEOPRAG-187. Aqui só existe a implementação em memória, suficiente para o
/// cliente e para os testes.
abstract interface class SessaoDeTokens {
  Future<String?> accessToken();

  /// Só o aplicador recebe refresh token (o portal usa apenas o access token).
  Future<String?> refreshToken();

  /// Grava o access token e, quando informado, o refresh token (o refresh é
  /// rotativo: cada renovação devolve um novo).
  Future<void> salvar({required String accessToken, String? refreshToken});

  /// Apaga os dois tokens (logout ou sessão perdida).
  Future<void> limpar();
}

/// [SessaoDeTokens] em memória: some quando o app fecha.
class SessaoDeTokensEmMemoria implements SessaoDeTokens {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<String?> accessToken() async => _accessToken;

  @override
  Future<String?> refreshToken() async => _refreshToken;

  @override
  Future<void> salvar({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    if (refreshToken != null) _refreshToken = refreshToken;
  }

  @override
  Future<void> limpar() async {
    _accessToken = null;
    _refreshToken = null;
  }
}
