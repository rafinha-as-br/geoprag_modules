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

  // Envio da outbox (aplicador_app/sincronizacao): motivo mostrado ao lado de
  // um registro que não pôde ser enviado ou foi recusado.

  static const String envioRespostaInesperada =
      'O servidor respondeu de um jeito inesperado. O envio será tentado de novo.';
  static const String envioSemResposta =
      'O servidor não confirmou este registro. O envio será tentado de novo.';
  static const String registroRecusado = 'Registro recusado pelo servidor.';
  static const String registroLocalIlegivel =
      'Registro local ilegível; não foi possível enviá-lo.';

  // GPS (aplicador_app/aplicacoes): sem posição o app não registra e orienta.

  static const String localizacaoPermissaoNegada =
      'O app precisa da sua localização para validar a chegada e registrar. '
      'Permita o acesso à localização e tente novamente.';
  static const String localizacaoPermissaoNegadaParaSempre =
      'O acesso à localização está bloqueado. Libere a localização para o app '
      'nas configurações do aparelho e tente novamente.';
  static const String localizacaoServicoDesligado =
      'O GPS está desligado. Ligue a localização do aparelho e tente '
      'novamente.';
  static const String localizacaoIndisponivel =
      'Não foi possível obter sua posição. Tente novamente.';
  static const String localizacaoTempoEsgotado =
      'Não foi possível obter sua posição a tempo. Vá para um local aberto e '
      'tente novamente.';
}
