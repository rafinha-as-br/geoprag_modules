import 'sync_json.dart';

/// Produto da lista `produtos` do pull (`id` e `nome`).
class ProdutoDto {
  const ProdutoDto({required this.id, required this.nome});

  final String id;
  final String nome;

  factory ProdutoDto.fromJson(Map<String, dynamic> json) => ProdutoDto(
    id: textoObrigatorio(json, 'id'),
    nome: textoObrigatorio(json, 'nome'),
  );
}

/// Subponto já registrado, como o pull e `GET /pontos` o devolvem.
///
/// [conflito] e [motivoConflito] são a extensão do contrato v0 que a API dá só
/// aos perfis de administração (GEOPRAG-199); o aplicador não os recebe, e para
/// o portal são opcionais (ausentes valem "sem conflito").
class SubpontoDto {
  const SubpontoDto({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.realizadoEm,
    required this.recebidoEm,
    this.conflito = false,
    this.motivoConflito,
  });

  final String id;
  final double latitude;
  final double longitude;

  /// Relógio do aparelho.
  final DateTime realizadoEm;

  /// Relógio do servidor.
  final DateTime recebidoEm;

  /// O registro chegou em desacordo com o estado do ponto.
  final bool conflito;

  /// `PONTO_REATRIBUIDO`, `PONTO_DESATIVADO`, `PONTO_INATIVO`,
  /// `DATA_JA_ATENDIDA` ou `DATA_CANCELADA`; o texto cru, para que um valor
  /// novo do servidor não quebre a leitura.
  final String? motivoConflito;

  factory SubpontoDto.fromJson(Map<String, dynamic> json) => SubpontoDto(
    id: textoObrigatorio(json, 'id'),
    latitude: numeroObrigatorio(json, 'latitude'),
    longitude: numeroObrigatorio(json, 'longitude'),
    realizadoEm: dataHoraObrigatoria(json, 'realizadoEm'),
    recebidoEm: dataHoraObrigatoria(json, 'recebidoEm'),
    conflito: booleanoOpcional(json, 'conflito') ?? false,
    motivoConflito: textoOpcional(json, 'motivoConflito'),
  );
}

/// Data agendada (`id` gerado pelo servidor).
class DataAgendadaDto {
  const DataAgendadaDto({
    required this.id,
    required this.data,
    required this.status,
  });

  final String id;

  /// Data de calendário, à meia-noite.
  final DateTime data;

  /// `PENDENTE`, `CONCLUIDA` ou `CANCELADA`.
  final String status;

  factory DataAgendadaDto.fromJson(Map<String, dynamic> json) =>
      DataAgendadaDto(
        id: textoObrigatorio(json, 'id'),
        data: dataDeCalendario(json, 'data'),
        status: textoObrigatorio(json, 'status'),
      );
}

class AgendamentoDto {
  const AgendamentoDto({
    required this.dataInicio,
    required this.intervaloDias,
    required this.quantidadeRecorrencias,
    required this.datas,
  });

  final DateTime dataInicio;
  final int intervaloDias;
  final int quantidadeRecorrencias;
  final List<DataAgendadaDto> datas;

  factory AgendamentoDto.fromJson(Map<String, dynamic> json) => AgendamentoDto(
    dataInicio: dataDeCalendario(json, 'dataInicio'),
    intervaloDias: inteiroObrigatorio(json, 'intervaloDias'),
    quantidadeRecorrencias: inteiroObrigatorio(json, 'quantidadeRecorrencias'),
    datas: [
      for (final data in listaDeObjetos(json, 'datas'))
        DataAgendadaDto.fromJson(data),
    ],
  );
}

/// `PontoDoAplicador` do pull: o `Ponto` do contrato restrito aos pontos
/// atribuídos ao aplicador. `bairroId` e `toleranciaAtrasoDias` chegam, mas o
/// domínio do app ainda não os guarda.
class PontoDoAplicadorDto {
  const PontoDoAplicadorDto({
    required this.id,
    required this.identificador,
    required this.nome,
    required this.bairro,
    required this.endereco,
    required this.dosagemMl,
    required this.distanciaEntreSubpontosMetros,
    required this.quantidadeDeSubpontos,
    required this.estado,
    required this.subpontos,
    this.bairroId,
    this.numeroReferencia,
    this.descricaoDoTrecho,
    this.larguraMetros,
    this.profundidadeMetros,
    this.velocidadeMetrosPorSegundo,
    this.toleranciaAtrasoDias,
    this.aplicadorId,
    this.estadoAnterior,
    this.agendamento,
  });

  final String id;
  final String identificador;
  final String nome;

  /// Nome do bairro.
  final String bairro;
  final String? bairroId;
  final String endereco;
  final String? numeroReferencia;
  final String? descricaoDoTrecho;
  final double? larguraMetros;
  final double? profundidadeMetros;
  final double? velocidadeMetrosPorSegundo;
  final double dosagemMl;
  final double distanciaEntreSubpontosMetros;
  final int quantidadeDeSubpontos;
  final int? toleranciaAtrasoDias;
  final String? aplicadorId;

  /// `ENDERECADA`, `DIRECIONADA`, `ATIVA`, `INATIVA` ou `DESATIVADO`.
  final String estado;
  final String? estadoAnterior;
  final AgendamentoDto? agendamento;
  final List<SubpontoDto> subpontos;

  factory PontoDoAplicadorDto.fromJson(Map<String, dynamic> json) {
    final agendamento = objetoOpcional(json, 'agendamento');
    return PontoDoAplicadorDto(
      id: textoObrigatorio(json, 'id'),
      identificador: textoObrigatorio(json, 'identificador'),
      nome: textoObrigatorio(json, 'nome'),
      bairro: textoObrigatorio(json, 'bairro'),
      bairroId: textoOpcional(json, 'bairroId'),
      endereco: textoObrigatorio(json, 'endereco'),
      numeroReferencia: textoOpcional(json, 'numeroReferencia'),
      descricaoDoTrecho: textoOpcional(json, 'descricaoDoTrecho'),
      larguraMetros: numeroOpcional(json, 'larguraMetros'),
      profundidadeMetros: numeroOpcional(json, 'profundidadeMetros'),
      velocidadeMetrosPorSegundo: numeroOpcional(
        json,
        'velocidadeMetrosPorSegundo',
      ),
      dosagemMl: numeroObrigatorio(json, 'dosagemMl'),
      distanciaEntreSubpontosMetros: numeroObrigatorio(
        json,
        'distanciaEntreSubpontosMetros',
      ),
      quantidadeDeSubpontos: inteiroObrigatorio(json, 'quantidadeDeSubpontos'),
      toleranciaAtrasoDias: inteiroOpcional(json, 'toleranciaAtrasoDias'),
      aplicadorId: textoOpcional(json, 'aplicadorId'),
      estado: textoObrigatorio(json, 'estado'),
      estadoAnterior: textoOpcional(json, 'estadoAnterior'),
      agendamento: agendamento == null
          ? null
          : AgendamentoDto.fromJson(agendamento),
      subpontos: [
        for (final s in listaDeObjetos(json, 'subpontos', opcional: true))
          SubpontoDto.fromJson(s),
      ],
    );
  }
}

/// Resposta de `GET /sync/pull`. Sem `desde` é o snapshot completo (o do
/// contrato v0, que não tinha `cursor` nem `removidos`); com `desde` traz só o
/// que mudou. [cursor] e [removidos] são a extensão do pull incremental.
class PullResponseDto {
  const PullResponseDto({
    required this.pontos,
    required this.produtos,
    required this.removidos,
    this.cursor,
  });

  final List<PontoDoAplicadorDto> pontos;
  final List<ProdutoDto> produtos;

  /// Instante do servidor para usar como `desde` no próximo pull. Ausente
  /// numa resposta no formato v0.
  final DateTime? cursor;

  /// Ids dos pontos retirados do aplicador. Vazia no snapshot.
  final List<String> removidos;

  factory PullResponseDto.fromJson(Map<String, dynamic> json) =>
      PullResponseDto(
        pontos: [
          for (final p in listaDeObjetos(json, 'pontos'))
            PontoDoAplicadorDto.fromJson(p),
        ],
        produtos: [
          for (final p in listaDeObjetos(json, 'produtos'))
            ProdutoDto.fromJson(p),
        ],
        cursor: dataHoraOpcional(json, 'cursor'),
        removidos: listaDeTextos(json, 'removidos', opcional: true),
      );
}
