import '../services/gerador_de_id.dart';
import 'ponto_de_aplicacao.dart';

/// Posição geográfica capturada no aparelho quando a aplicação foi iniciada.
class LocalizacaoCapturada {
  const LocalizacaoCapturada({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalizacaoCapturada &&
          other.latitude == latitude &&
          other.longitude == longitude);

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// Uma aplicação registrada em campo: agrupa os [subpontos] feitos numa mesma
/// visita a um [PontoDeAplicacao] para atender uma data agendada.
///
/// **Append-only** (GEOPRAG-188): o registro nunca é editado nem apagado. Não
/// há `copyWith` nem setters; o único jeito de "crescer" é [comSubponto], que
/// devolve uma aplicação nova com o subponto acrescentado ao fim. É o que
/// torna o reenvio da sincronização idempotente: o [id] e o [id] de cada
/// [Subponto] são UUIDs v4 gerados no aparelho e nunca mudam.
class Aplicacao {
  Aplicacao({
    required this.id,
    required this.pontoId,
    required this.aplicadorId,
    required this.dataAgendadaId,
    required this.produtoId,
    required this.realizadoEm,
    required this.localizacao,
    List<Subponto> subpontos = const [],
  }) : subpontos = List.unmodifiable(subpontos);

  /// Cria uma aplicação nova, com [id] UUID v4 do [gerador].
  factory Aplicacao.nova({
    required GeradorDeId gerador,
    required String pontoId,
    required String aplicadorId,
    required String dataAgendadaId,
    required String produtoId,
    required DateTime realizadoEm,
    required LocalizacaoCapturada localizacao,
  }) => Aplicacao(
    id: gerador.gerar(),
    pontoId: pontoId,
    aplicadorId: aplicadorId,
    dataAgendadaId: dataAgendadaId,
    produtoId: produtoId,
    realizadoEm: realizadoEm,
    localizacao: localizacao,
  );

  /// UUID v4 gerado no aplicativo.
  final String id;
  final String pontoId;

  /// Aplicador que fez o registro (o do token, nunca digitado).
  final String aplicadorId;

  /// Data agendada atendida por esta aplicação (`id` vindo do servidor).
  final String dataAgendadaId;

  /// Produto selecionado pelo aplicador.
  final String produtoId;

  /// Relógio do aparelho. Preserva o fuso do aparelho quando o valor é local.
  final DateTime realizadoEm;
  final LocalizacaoCapturada localizacao;

  /// Subpontos já registrados, do mais antigo para o mais recente.
  final List<Subponto> subpontos;

  /// Nova aplicação com [subponto] acrescentado ao fim; a atual não muda.
  Aplicacao comSubponto(Subponto subponto) => Aplicacao(
    id: id,
    pontoId: pontoId,
    aplicadorId: aplicadorId,
    dataAgendadaId: dataAgendadaId,
    produtoId: produtoId,
    realizadoEm: realizadoEm,
    localizacao: localizacao,
    subpontos: [...subpontos, subponto],
  );
}
