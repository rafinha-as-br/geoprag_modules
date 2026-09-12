/// Quem executou a ação registrada por um [EventoAuditoria]: um usuário do
/// Portal Administrador (com o perfil que tinha no momento) ou um aplicador
/// em campo (App Aplicador). Sealed para forçar tratamento exaustivo em
/// qualquer consumidor futuro (ex.: uma tela de histórico).
sealed class AutorEvento {
  const AutorEvento();
}

class AutorUsuario extends AutorEvento {
  final String email;
  final String perfil;

  const AutorUsuario({required this.email, required this.perfil});
}

class AutorAplicadorEmCampo extends AutorEvento {
  final String aplicadorId;

  const AutorAplicadorEmCampo({required this.aplicadorId});
}

/// Registro append-only de uma mudança de estado num ponto de aplicação
/// (GEOPRAG-113) — nem este evento nem o ponto que ele descreve são
/// apagados quando o ponto é desativado.
///
/// [dataHoraOcorrencia] e [dataHoraRegistro] são deliberadamente distintas:
/// a primeira é quando a ação aconteceu de fato (pode ser retroativa, ex.:
/// aplicação registrada depois em campo sem sinal); a segunda é quando o
/// evento chegou a este repositório.
class EventoAuditoria {
  final String id;
  final String pontoAfetadoId;
  final String tipo;
  final AutorEvento autor;
  final DateTime dataHoraOcorrencia;
  final DateTime dataHoraRegistro;
  final Map<String, dynamic> payload;
  final String? loteId;

  EventoAuditoria({
    required this.id,
    required this.pontoAfetadoId,
    required this.tipo,
    required this.autor,
    required this.dataHoraOcorrencia,
    required this.dataHoraRegistro,
    this.payload = const {},
    this.loteId,
  }) : assert(
         !dataHoraRegistro.isBefore(dataHoraOcorrencia),
         'dataHoraRegistro não pode ser anterior a dataHoraOcorrencia — não '
         'é possível registrar um evento antes dele ter acontecido.',
       );
}
