import '../../src/api/sync/sync_json.dart'
    show formatarDataDeCalendario, formatarDataHoraComOffset;
import '../../src/entities/aplicacao.dart';
import '../../src/entities/ponto_de_aplicacao.dart';
import 'item_da_outbox.dart';

/// Conversão entre as entidades do domínio e as linhas do banco local. Fica na
/// camada de dados: as entidades não conhecem SQL (GEOPRAG-189).
class ConversoresDoBanco {
  const ConversoresDoBanco._();

  /// Instante com o offset do aparelho (`2026-10-21T14:30:00-03:00`).
  static String textoDoInstante(DateTime instante) =>
      formatarDataHoraComOffset(instante);

  /// Instante lido de volta, no fuso local do aparelho.
  static DateTime instanteDoTexto(String texto) =>
      DateTime.parse(texto).toLocal();

  /// Data de calendário `yyyy-MM-dd` lida como meia-noite local.
  static DateTime dataDoTexto(String texto) => DateTime.parse(texto);

  static Map<String, Object?> linhaDoPonto(PontoDeAplicacao ponto) {
    final agendamento = ponto.agendamento;
    return {
      'id': ponto.id,
      'identificador': ponto.identificador,
      'nome': ponto.nome,
      'bairro': ponto.bairro,
      'endereco': ponto.endereco,
      'numero_referencia': ponto.numeroReferencia,
      'descricao_do_trecho': ponto.descricaoDoTrecho,
      'largura_metros': ponto.larguraMetros,
      'profundidade_metros': ponto.profundidadeMetros,
      'velocidade_metros_por_segundo': ponto.velocidadeMetrosPorSegundo,
      'dosagem_ml': ponto.dosagemMl,
      'distancia_entre_subpontos_metros': ponto.distanciaEntreSubpontosMetros,
      'quantidade_de_subpontos': ponto.quantidadeDeSubpontos,
      'aplicador_id': ponto.aplicadorId,
      'estado': ponto.estado.name,
      'estado_anterior': ponto.estadoAnterior?.name,
      'agendamento_data_inicio': agendamento == null
          ? null
          : formatarDataDeCalendario(agendamento.dataInicio),
      'agendamento_intervalo_dias': agendamento?.intervaloDias,
      'agendamento_quantidade_recorrencias':
          agendamento?.quantidadeRecorrencias,
    };
  }

  static PontoDeAplicacao pontoDaLinha(
    Map<String, Object?> linha, {
    required List<Map<String, Object?>> datas,
    required List<Subponto> subpontos,
  }) {
    final dataInicio = linha['agendamento_data_inicio'] as String?;
    final estadoAnterior = linha['estado_anterior'] as String?;
    return PontoDeAplicacao(
      id: linha['id']! as String,
      identificador: linha['identificador']! as String,
      nome: linha['nome']! as String,
      bairro: linha['bairro']! as String,
      endereco: linha['endereco']! as String,
      numeroReferencia: linha['numero_referencia']! as String,
      descricaoDoTrecho: linha['descricao_do_trecho']! as String,
      larguraMetros: (linha['largura_metros']! as num).toDouble(),
      profundidadeMetros: (linha['profundidade_metros']! as num).toDouble(),
      velocidadeMetrosPorSegundo:
          (linha['velocidade_metros_por_segundo']! as num).toDouble(),
      dosagemMl: (linha['dosagem_ml']! as num).toDouble(),
      distanciaEntreSubpontosMetros:
          (linha['distancia_entre_subpontos_metros']! as num).toDouble(),
      quantidadeDeSubpontos: linha['quantidade_de_subpontos']! as int,
      aplicadorId: linha['aplicador_id'] as String?,
      estado: EstadoPontoDeAplicacao.values.byName(linha['estado']! as String),
      estadoAnterior: estadoAnterior == null
          ? null
          : EstadoPontoDeAplicacao.values.byName(estadoAnterior),
      agendamento: dataInicio == null
          ? null
          : Agendamento(
              dataInicio: dataDoTexto(dataInicio),
              intervaloDias: linha['agendamento_intervalo_dias']! as int,
              quantidadeRecorrencias:
                  linha['agendamento_quantidade_recorrencias']! as int,
              datas: [
                for (final d in datas)
                  DataAgendada(
                    id: d['id']! as String,
                    data: dataDoTexto(d['data']! as String),
                    status: StatusDataAgendada.values.byName(
                      d['status']! as String,
                    ),
                  ),
              ],
            ),
      subpontos: subpontos,
    );
  }

  static Map<String, Object?> linhaDaData(
    String pontoId,
    DataAgendada data,
    int ordem,
  ) => {
    'id': data.id,
    'ponto_id': pontoId,
    'data': formatarDataDeCalendario(data.data),
    'status': data.status.name,
    'ordem': ordem,
  };

  static Map<String, Object?> linhaDoSubponto(
    Subponto subponto, {
    required String pontoId,
    String? aplicacaoId,
  }) => {
    'id': subponto.id,
    'ponto_id': pontoId,
    'aplicacao_id': aplicacaoId,
    'latitude': subponto.latitude,
    'longitude': subponto.longitude,
    'realizado_em': textoDoInstante(subponto.realizadoEm),
    'realizado_em_ms': subponto.realizadoEm.millisecondsSinceEpoch,
    'registrado_em': textoDoInstante(subponto.registradoEm),
  };

  static Subponto subpontoDaLinha(Map<String, Object?> linha) => Subponto(
    id: linha['id']! as String,
    latitude: (linha['latitude']! as num).toDouble(),
    longitude: (linha['longitude']! as num).toDouble(),
    realizadoEm: instanteDoTexto(linha['realizado_em']! as String),
    registradoEm: instanteDoTexto(linha['registrado_em']! as String),
  );

  static Map<String, Object?> linhaDaAplicacao(Aplicacao aplicacao) => {
    'id': aplicacao.id,
    'ponto_id': aplicacao.pontoId,
    'aplicador_id': aplicacao.aplicadorId,
    'data_agendada_id': aplicacao.dataAgendadaId,
    'produto_id': aplicacao.produtoId,
    'realizado_em': textoDoInstante(aplicacao.realizadoEm),
    'latitude': aplicacao.localizacao.latitude,
    'longitude': aplicacao.localizacao.longitude,
  };

  static Aplicacao aplicacaoDaLinha(
    Map<String, Object?> linha,
    List<Subponto> subpontos,
  ) => Aplicacao(
    id: linha['id']! as String,
    pontoId: linha['ponto_id']! as String,
    aplicadorId: linha['aplicador_id']! as String,
    dataAgendadaId: linha['data_agendada_id']! as String,
    produtoId: linha['produto_id']! as String,
    realizadoEm: instanteDoTexto(linha['realizado_em']! as String),
    localizacao: LocalizacaoCapturada(
      latitude: (linha['latitude']! as num).toDouble(),
      longitude: (linha['longitude']! as num).toDouble(),
    ),
    subpontos: subpontos,
  );

  static Map<String, Object?> linhaDoItem(ItemDaOutbox item) => {
    'id': item.id,
    'tipo': item.tipo.valor,
    'ponto_id': item.pontoId,
    'payload': item.payload,
    'estado': item.estado.valor,
    'tentativas': item.tentativas,
    'ultimo_erro': item.ultimoErro,
    'criado_em': textoDoInstante(item.criadoEm),
    'criado_em_ms': item.criadoEm.millisecondsSinceEpoch,
    'ultima_tentativa_em': item.ultimaTentativaEm == null
        ? null
        : textoDoInstante(item.ultimaTentativaEm!),
  };

  static ItemDaOutbox itemDaLinha(Map<String, Object?> linha) {
    final ultimaTentativa = linha['ultima_tentativa_em'] as String?;
    return ItemDaOutbox(
      id: linha['id']! as String,
      tipo: TipoDoItemDaOutbox.doValor(linha['tipo']! as String),
      pontoId: linha['ponto_id']! as String,
      payload: linha['payload']! as String,
      estado: EstadoDoItemDaOutbox.doValor(linha['estado']! as String),
      tentativas: linha['tentativas']! as int,
      ultimoErro: linha['ultimo_erro'] as String?,
      criadoEm: instanteDoTexto(linha['criado_em']! as String),
      ultimaTentativaEm: ultimaTentativa == null
          ? null
          : instanteDoTexto(ultimaTentativa),
    );
  }
}
