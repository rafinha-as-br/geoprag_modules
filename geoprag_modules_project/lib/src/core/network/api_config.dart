/// Configuração do cliente HTTP.
///
/// A URL base vem do ambiente de compilação (`--dart-define=API_BASE_URL=...`),
/// nunca de código: ex.: `http://10.0.2.2:8080` no emulador Android ou
/// `http://localhost:8080` no portal Web.
class ApiConfig {
  ApiConfig({
    required String baseUrl,
    this.timeoutPadrao = const Duration(seconds: 15),
    this.timeoutPrimeiraChamada = const Duration(seconds: 60),
  }) : baseUrl = _normalizar(baseUrl) {
    if (this.baseUrl.isEmpty) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'A URL base não pode ser vazia.',
      );
    }
  }

  /// Lê `API_BASE_URL` do ambiente de compilação.
  ///
  /// Lança [StateError] se a variável não foi definida, para que a falta de
  /// configuração apareça logo na primeira chamada em vez de virar uma
  /// requisição para um endereço vazio.
  factory ApiConfig.doAmbiente() {
    const valor = String.fromEnvironment('API_BASE_URL');
    if (valor.trim().isEmpty) {
      throw StateError(
        'API_BASE_URL não definida. Compile com '
        '--dart-define=API_BASE_URL=http://host:porta.',
      );
    }
    return ApiConfig(baseUrl: valor);
  }

  /// Prefixo de todos os endpoints de negócio (contrato v0).
  static const String prefixo = '/api/v1';

  /// Servidor sem barra final nem o prefixo `/api/v1`.
  final String baseUrl;

  /// Tempo máximo de conexão e de resposta nas chamadas normais.
  final Duration timeoutPadrao;

  /// Tempo máximo até a **primeira chamada bem-sucedida**: tolera um servidor
  /// lento para subir (o cold start do contêiner).
  final Duration timeoutPrimeiraChamada;

  /// Base de todas as rotas: `<baseUrl>/api/v1`.
  String get baseUrlDaApi => '$baseUrl$prefixo';

  static String _normalizar(String url) {
    var limpa = url.trim();
    while (limpa.endsWith('/')) {
      limpa = limpa.substring(0, limpa.length - 1);
    }
    if (limpa.endsWith(prefixo)) {
      limpa = limpa.substring(0, limpa.length - prefixo.length);
    }
    return limpa;
  }
}
