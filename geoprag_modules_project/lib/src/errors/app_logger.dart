import 'dart:developer' as developer;

/// Ponto único de log de erros não tratados/inesperados capturados pelos
/// Cubits do pacote.
///
/// Hoje escreve via `dart:developer.log` (visível no DevTools e no console
/// de teste), o suficiente para não perder o rastro do erro em
/// desenvolvimento. Quando o projeto integrar uma ferramenta de crash
/// reporting (ex.: Sentry, Firebase Crashlytics), apenas este arquivo
/// precisa mudar — nenhum Cubit que já usa [AppLogger.error] precisa ser
/// tocado.
class AppLogger {
  const AppLogger._();

  /// Registra uma exceção inesperada (não mapeada para uma falha de negócio
  /// conhecida) capturada por um Cubit.
  ///
  /// [origem] identifica de onde veio o erro (ex.:
  /// `'AplicacaoAtualCubit._carregar'`) para localizar rapidamente o Cubit
  /// certo ao investigar um problema relatado em produção.
  static void error(String origem, Object erro, StackTrace stackTrace) {
    developer.log(
      'Erro não tratado em $origem',
      name: 'GeopragModules',
      error: erro,
      stackTrace: stackTrace,
      level: 1000, // SEVERE
    );
  }
}
