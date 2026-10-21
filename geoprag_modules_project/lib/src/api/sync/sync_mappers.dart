import '../../entities/aplicacao.dart';
import '../../entities/ponto_de_aplicacao.dart';
import 'pull_dtos.dart';
import 'registro_dtos.dart';

/// Conversão entre as entidades do domínio e os payloads de sincronização.
/// Fica fora do domínio: as entidades não conhecem JSON nem DTO (GEOPRAG-188).
class SyncMappers {
  const SyncMappers._();

  /// Itens do lote para uma [Aplicacao]: um por subponto, todos com o mesmo
  /// `aplicacaoId`, `pontoId`, `dataAgendadaId` e `produtoId` da aplicação.
  /// Aplicação sem subpontos não gera item.
  static List<ItemDeRegistroDto> itensDaAplicacao(Aplicacao aplicacao) => [
    for (final subponto in aplicacao.subpontos)
      ItemDeRegistroDto(
        id: subponto.id,
        aplicacaoId: aplicacao.id,
        pontoId: aplicacao.pontoId,
        dataAgendadaId: aplicacao.dataAgendadaId,
        produtoId: aplicacao.produtoId,
        latitude: subponto.latitude,
        longitude: subponto.longitude,
        realizadoEm: subponto.realizadoEm,
      ),
  ];

  /// Lote de envio com os subpontos de [aplicacoes], na ordem recebida.
  static LoteDeRegistroDto loteDeAplicacoes({
    required String dispositivoId,
    required Iterable<Aplicacao> aplicacoes,
  }) => LoteDeRegistroDto(
    dispositivoId: dispositivoId,
    itens: [for (final a in aplicacoes) ...itensDaAplicacao(a)],
  );

  /// [SubpontoDto] do pull → [Subponto]; `recebidoEm` (servidor) vira
  /// `registradoEm`.
  static Subponto paraSubponto(SubpontoDto dto) => Subponto(
    id: dto.id,
    latitude: dto.latitude,
    longitude: dto.longitude,
    realizadoEm: dto.realizadoEm,
    registradoEm: dto.recebidoEm,
    conflito: dto.conflito,
    motivoConflito: dto.motivoConflito == null
        ? null
        : _motivoDeConflito(dto.motivoConflito!),
  );

  /// Motivo que o servidor mandar e esta versão não conhecer vira
  /// [MotivoDeConflito.desconhecido]: a marca de conflito continua visível.
  static MotivoDeConflito _motivoDeConflito(String valor) => switch (valor) {
    'PONTO_REATRIBUIDO' => MotivoDeConflito.pontoReatribuido,
    'PONTO_DESATIVADO' => MotivoDeConflito.pontoDesativado,
    'PONTO_INATIVO' => MotivoDeConflito.pontoInativo,
    'DATA_JA_ATENDIDA' => MotivoDeConflito.dataJaAtendida,
    'DATA_CANCELADA' => MotivoDeConflito.dataCancelada,
    _ => MotivoDeConflito.desconhecido,
  };

  /// [PontoDoAplicadorDto] do pull → [PontoDeAplicacao].
  ///
  /// O contrato torna opcionais `numeroReferencia`, `descricaoDoTrecho` e as
  /// três medidas do trecho, mas a entidade as exige. Quando ausentes ficam
  /// como texto vazio e `0` (vazão `0`, "sem medida"), valores que o
  /// aplicador não exibe; o portal (GEOPRAG-195) deve tornar esses campos
  /// opcionais na entidade. `bairroId` e `toleranciaAtrasoDias` não têm campo
  /// na entidade e são descartados.
  ///
  /// Lança [FormatException] para `estado`/`status` desconhecidos e as
  /// exceções da própria entidade se o ponto violar uma invariante (ex.:
  /// ativo sem aplicador).
  static PontoDeAplicacao paraPonto(PontoDoAplicadorDto dto) {
    return PontoDeAplicacao(
      id: dto.id,
      identificador: dto.identificador,
      nome: dto.nome,
      bairro: dto.bairro,
      endereco: dto.endereco,
      numeroReferencia: dto.numeroReferencia ?? '',
      descricaoDoTrecho: dto.descricaoDoTrecho ?? '',
      larguraMetros: dto.larguraMetros ?? 0,
      profundidadeMetros: dto.profundidadeMetros ?? 0,
      velocidadeMetrosPorSegundo: dto.velocidadeMetrosPorSegundo ?? 0,
      dosagemMl: dto.dosagemMl,
      distanciaEntreSubpontosMetros: dto.distanciaEntreSubpontosMetros,
      quantidadeDeSubpontos: dto.quantidadeDeSubpontos,
      aplicadorId: dto.aplicadorId,
      estado: _estado(dto.estado),
      estadoAnterior: dto.estadoAnterior == null
          ? null
          : _estado(dto.estadoAnterior!),
      agendamento: dto.agendamento == null
          ? null
          : _agendamento(dto.agendamento!),
      subpontos: [for (final s in dto.subpontos) paraSubponto(s)],
    );
  }

  static Agendamento _agendamento(AgendamentoDto dto) => Agendamento(
    dataInicio: dto.dataInicio,
    intervaloDias: dto.intervaloDias,
    quantidadeRecorrencias: dto.quantidadeRecorrencias,
    datas: [
      for (final d in dto.datas)
        DataAgendada(id: d.id, data: d.data, status: _statusData(d.status)),
    ],
  );

  static EstadoPontoDeAplicacao _estado(String valor) => switch (valor) {
    'ENDERECADA' => EstadoPontoDeAplicacao.enderecada,
    'DIRECIONADA' => EstadoPontoDeAplicacao.direcionada,
    'ATIVA' => EstadoPontoDeAplicacao.ativa,
    'INATIVA' => EstadoPontoDeAplicacao.inativa,
    'DESATIVADO' => EstadoPontoDeAplicacao.desativado,
    _ => throw FormatException('Estado do ponto desconhecido: "$valor".'),
  };

  static StatusDataAgendada _statusData(String valor) => switch (valor) {
    'PENDENTE' => StatusDataAgendada.pendente,
    'CONCLUIDA' => StatusDataAgendada.concluida,
    'CANCELADA' => StatusDataAgendada.cancelada,
    _ => throw FormatException('Status da data desconhecido: "$valor".'),
  };
}
