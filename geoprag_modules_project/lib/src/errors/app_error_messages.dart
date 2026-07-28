/// Mensagens de erro genéricas e reutilizáveis, exibidas quando um Cubit
/// captura uma exceção que não é uma falha de negócio conhecida (ver
/// [EntidadeNaoEncontradaException] em `app_exceptions.dart`).
///
/// Centralizar aqui evita copiar o mesmo texto à mão em cada Cubit e
/// permite trocar a mensagem (ou traduzi-la) em um único lugar.
class AppErrorMessages {
  const AppErrorMessages._();

  /// Mensagem padrão para qualquer erro inesperado durante um carregamento
  /// ou ação — nunca expõe detalhe técnico da exceção original.
  static const String carregamentoGenerico =
      'Não foi possível carregar os dados. Tente novamente.';
}
