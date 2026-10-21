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

  // Camada HTTP (src/api): textos de último recurso, usados quando o
  // servidor não envia um `detail` próprio. Nunca incluem detalhe técnico.

  static const String semConexao =
      'Sem conexão com o servidor. Verifique a internet e tente novamente.';
  static const String tempoEsgotado =
      'O servidor demorou para responder. Tente novamente.';
  static const String sessaoExpirada = 'Sua sessão expirou. Entre novamente.';
  static const String acessoNegado =
      'Você não tem permissão para realizar esta ação.';
  static const String naoEncontrado = 'Registro não encontrado.';
  static const String operacaoNaoPermitida =
      'Esta operação não é permitida no estado atual.';
  static const String requisicaoInvalida =
      'Não foi possível processar a solicitação. Verifique os dados.';
  static const String erroDoServidor =
      'O servidor encontrou um problema. Tente novamente em instantes.';

  /// A API aceitou a ação, mas reler o ponto falhou (rede, servidor).
  static const String acaoFeitaSemAtualizarATela =
      'A ação foi concluída, mas não foi possível atualizar a tela. '
      'Recarregue a página.';

  /// Ação do portal que ainda não foi ligada à API (GEOPRAG-198).
  static const String acaoIndisponivelNestaVersao =
      'Esta ação ainda não está disponível nesta versão.';
}
