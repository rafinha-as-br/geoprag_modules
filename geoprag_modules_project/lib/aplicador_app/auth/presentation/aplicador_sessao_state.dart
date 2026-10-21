import '../core/usuario.dart';

/// Quem está logado no App Aplicador — fonte única consultada pelo guard de
/// rota e pelas telas que precisam do `id` do aplicador (GEOPRAG-187).
sealed class AplicadorSessaoState {
  const AplicadorSessaoState();
}

class AplicadorSessaoSemAcesso extends AplicadorSessaoState {
  const AplicadorSessaoSemAcesso();
}

class AplicadorSessaoAutenticada extends AplicadorSessaoState {
  const AplicadorSessaoAutenticada(this.usuario);

  final Usuario usuario;
}
