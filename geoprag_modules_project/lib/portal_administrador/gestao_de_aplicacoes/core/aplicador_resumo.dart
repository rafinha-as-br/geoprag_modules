import '../../../src/entities/usuario.dart';

/// Aplicador como a Gestão de Aplicações o enxerga: o suficiente para mostrar
/// o responsável de um ponto e escolher um candidato (`AplicadorResumo` do
/// contrato v0).
///
/// Não é o `Aplicador` do módulo de Gerenciamento de Aplicadores: aquele traz
/// e-mail, CPF e endereço, que a API não expõe a este fluxo de propósito.
class AplicadorResumo {
  const AplicadorResumo({
    required this.id,
    required this.nome,
    required this.status,
  });

  final String id;
  final String nome;
  final UsuarioStatus status;

  /// Só aplicador ativo pode receber um ponto (o servidor responde `409` aos
  /// demais).
  bool get ativo => status == UsuarioStatus.ativo;
}
