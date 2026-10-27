/// Exceções da camada HTTP (GEOPRAG-185).
///
/// O [ApiClient] traduz toda falha de rede ou resposta de erro numa destas
/// exceções, ou numa das já existentes do pacote (`EntidadeNaoEncontradaException`
/// para 404 e `OperacaoNaoPermitidaException` para 409). Todas carregam uma
/// `mensagemAmigavel` pronta para a UI: nunca há detalhe técnico, stack trace,
/// URL ou dado do pedido nela, e respostas `5xx` nunca repassam o texto do
/// servidor.
library;

/// Item de `errors[]` de um erro de validação (`400 VALIDACAO_INVALIDA`).
class ErroDeCampo {
  const ErroDeCampo({required this.campo, required this.mensagem});

  final String campo;
  final String mensagem;

  @override
  String toString() => 'ErroDeCampo($campo)';
}

/// Base das exceções específicas da API.
abstract class ApiException implements Exception {
  const ApiException(this.mensagemAmigavel, {this.codigo, this.status});

  /// Mensagem segura para exibição direta ao usuário final.
  final String mensagemAmigavel;

  /// `code` estável do servidor (ex.: `CREDENCIAIS_INVALIDAS`), quando houver.
  final String? codigo;

  /// Status HTTP, quando a falha veio de uma resposta.
  final int? status;

  @override
  String toString() => '$runtimeType($codigo): $mensagemAmigavel';
}

/// Sem rede, servidor inalcançável ou tempo esgotado. Para o app é "offline":
/// nunca deve causar perda de registro.
class FalhaDeConexaoException extends ApiException {
  const FalhaDeConexaoException(
    super.mensagemAmigavel, {
    this.tempoEsgotado = false,
  });

  /// `true` quando o servidor foi alcançado mas não respondeu a tempo.
  final bool tempoEsgotado;
}

/// `401`: token ausente, inválido ou expirado, credenciais incorretas ou
/// refresh token inválido. A sessão não pode ser recuperada sem novo login.
class NaoAutenticadoException extends ApiException {
  const NaoAutenticadoException(super.mensagemAmigavel, {super.codigo})
    : super(status: 401);
}

/// `403`: perfil sem permissão ou usuário desativado.
class AcessoNegadoException extends ApiException {
  const AcessoNegadoException(super.mensagemAmigavel, {super.codigo})
    : super(status: 403);
}

/// `400`, `413` ou `422`: pedido inválido. [erros] traz o detalhe por campo.
class RequisicaoInvalidaException extends ApiException {
  const RequisicaoInvalidaException(
    super.mensagemAmigavel, {
    super.codigo,
    super.status,
    this.erros = const [],
  });

  final List<ErroDeCampo> erros;
}

/// `5xx`: falha do servidor. A mensagem é sempre genérica.
class ErroDoServidorException extends ApiException {
  const ErroDoServidorException(super.mensagemAmigavel, {super.status});
}
