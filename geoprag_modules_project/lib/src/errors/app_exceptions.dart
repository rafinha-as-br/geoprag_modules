/// Exceção lançada pela camada de dados (`*RepositoryImpl`) — ou por um
/// Cubit, ao validar uma condição de negócio equivalente — quando uma
/// entidade solicitada por id (ou uma condição de "nada encontrado") não
/// existe na fonte de dados.
///
/// Carrega uma [mensagemAmigavel] já pronta para exibição direta na UI: o
/// texto nunca deve conter detalhes técnicos (tipo da exceção, stack trace),
/// apenas uma frase de negócio, ex.: `Aplicador "123" não encontrado.`.
///
/// Cubits devem capturar este tipo especificamente (`on
/// EntidadeNaoEncontradaException`) e mostrar [mensagemAmigavel] direto na
/// tela, antes de qualquer `catch` genérico — ver `app_logger.dart` e
/// `app_error_messages.dart` para o restante do contrato de erro.
class EntidadeNaoEncontradaException implements Exception {
  const EntidadeNaoEncontradaException(this.mensagemAmigavel);

  /// Mensagem segura para exibição direta ao usuário final.
  final String mensagemAmigavel;

  @override
  String toString() => 'EntidadeNaoEncontradaException: $mensagemAmigavel';
}

/// Exceção lançada pela camada de dados quando uma operação de criação
/// viola uma restrição de unicidade de negócio (ex.: e-mail institucional
/// já cadastrado como identificador de login). Mesma semântica de
/// [mensagemAmigavel] de [EntidadeNaoEncontradaException].
class EntidadeDuplicadaException implements Exception {
  const EntidadeDuplicadaException(this.mensagemAmigavel);

  final String mensagemAmigavel;

  @override
  String toString() => 'EntidadeDuplicadaException: $mensagemAmigavel';
}
