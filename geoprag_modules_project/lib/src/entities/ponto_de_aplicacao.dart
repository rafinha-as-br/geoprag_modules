import '../errors/app_exceptions.dart';

/// Ciclo de vida de um [PontoDeAplicacao], do cadastro à desativação.
///
/// Não confundir com "atrasado"/"em dia", que são condições temporais
/// derivadas do histórico de execuções — e não estados do cadastro.
enum EstadoPontoDeAplicacao {
  /// Cadastrado, ainda sem aplicador responsável.
  enderecada,

  /// Já tem aplicador responsável, mas o ciclo ainda não foi ativado.
  direcionada,

  /// Em operação: o aplicador responsável executa o ciclo neste ponto.
  ativa,

  /// Operação suspensa temporariamente, mantendo o cadastro utilizável.
  inativa,

  /// Retirado de operação. Um ponto nunca é excluído, apenas desativado
  /// ("Módulo - Gestão de Aplicações", seção 5).
  desativado,
}

/// Situação de uma data agendada dentro de um [Agendamento].
enum StatusDataAgendada {
  /// Ainda não chegou, ou já passou mas não foi registrada.
  pendente,

  /// Aplicação já registrada para esta data (ver [Subponto.registradoEm]).
  concluida,

  /// Removida do agendamento sem gerar aplicação — ex.: o ciclo foi
  /// desativado antes de chegar nela.
  cancelada,
}

/// Uma data prevista dentro de um [Agendamento], editável individualmente
/// depois de gerada (GEOPRAG-75) — por isso é um registro próprio, e não
/// apenas um índice calculado a partir de [Agendamento.dataInicio].
class DataAgendada {
  final DateTime data;
  final StatusDataAgendada status;

  const DataAgendada({
    required this.data,
    this.status = StatusDataAgendada.pendente,
  });

  DataAgendada copyWith({DateTime? data, StatusDataAgendada? status}) {
    return DataAgendada(
      data: data ?? this.data,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DataAgendada && other.data == data && other.status == status);

  @override
  int get hashCode => Object.hash(data, status);
}

/// Agendamento do ciclo de aplicações de um [PontoDeAplicacao]: quando a
/// primeira aplicação é esperada, o intervalo entre uma e a próxima, e
/// quantas recorrências compõem o ciclo.
///
/// Guarda a lista de datas já gerada (e não só os três parâmetros que a
/// originaram) porque cada data pode ser editada individualmente depois
/// (GEOPRAG-75, parte de recorrência) — se fosse recalculada sempre a partir
/// de [dataInicio]/[intervaloDias], uma edição pontual seria perdida na
/// próxima leitura.
class Agendamento {
  final DateTime dataInicio;
  final int intervaloDias;
  final int quantidadeRecorrencias;
  final List<DataAgendada> datas;

  Agendamento({
    required this.dataInicio,
    required this.intervaloDias,
    required this.quantidadeRecorrencias,
    required List<DataAgendada> datas,
  }) : datas = List.unmodifiable(datas);

  /// Gera um [Agendamento] novo, com as datas espaçadas por [intervaloDias]
  /// a partir de [dataInicio] — a primeira geração de um ciclo, antes de
  /// qualquer edição individual de data.
  factory Agendamento.gerar({
    required DateTime dataInicio,
    required int intervaloDias,
    required int quantidadeRecorrencias,
  }) {
    return Agendamento(
      dataInicio: dataInicio,
      intervaloDias: intervaloDias,
      quantidadeRecorrencias: quantidadeRecorrencias,
      datas: [
        for (var i = 0; i < quantidadeRecorrencias; i++)
          DataAgendada(data: dataInicio.add(Duration(days: intervaloDias * i))),
      ],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Agendamento) return false;
    if (other.dataInicio != dataInicio ||
        other.intervaloDias != intervaloDias ||
        other.quantidadeRecorrencias != quantidadeRecorrencias ||
        other.datas.length != datas.length) {
      return false;
    }
    for (var i = 0; i < datas.length; i++) {
      if (other.datas[i] != datas[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    dataInicio,
    intervaloDias,
    quantidadeRecorrencias,
    Object.hashAll(datas),
  );
}

/// Uma aplicação do produto registrada ao longo do trecho de um
/// [PontoDeAplicacao].
///
/// Guarda dois carimbos distintos porque eles divergem na prática: o
/// aplicador trabalha em campo sem rede, a aplicação é salva no dispositivo
/// e só sobe ao sistema depois ("Módulo - Gestão de Aplicações", seção 5).
/// [realizadoEm] é o instante da aplicação física — a única data válida para
/// auditoria; [registradoEm] é quando o sistema recebeu o registro.
class Subponto {
  final double latitude;
  final double longitude;
  final DateTime realizadoEm;
  final DateTime registradoEm;

  const Subponto({
    required this.latitude,
    required this.longitude,
    required this.realizadoEm,
    required this.registradoEm,
  });
}

/// Um ponto de aplicação: o trecho cadastrado pelo administrador onde o
/// produto biológico é aplicado, com os parâmetros hidrológicos do trecho, o
/// aplicador responsável e as aplicações já realizadas ([subpontos]).
///
/// Entidade única do domínio, compartilhada pelos dois apps — ver "Conceitos
/// - Ponto de Aplicação e Subponto" no Confluence para a definição de
/// negócio.
///
/// **Sem latitude/longitude no cadastro:** o administrador cadastra o ponto
/// por endereço; nenhuma coordenada é informada aqui. As únicas coordenadas
/// da entidade nascem em campo, dentro de [subpontos].
class PontoDeAplicacao {
  final String id;

  /// Nome dado pelo administrador (ex.: "Córrego Gasparinho - Margem
  /// Esquerda").
  final String nome;

  /// Código curto gerado pelo sistema (ex.: `#CEN1`). Convive com [nome]
  /// para busca e conferência rápida — nunca substitui o nome.
  final String identificador;

  final String bairro;
  final String endereco;

  /// Número ou ponto de referência do endereço, em texto livre — nem todo
  /// trecho de córrego tem número.
  final String numeroReferencia;

  final String descricaoDoTrecho;

  /// Parâmetros hidrológicos brutos medidos no trecho, em metros e m/s.
  ///
  /// São eles que ficam persistidos — e não a vazão. Ver [vazao].
  final double larguraMetros;
  final double profundidadeMetros;
  final double velocidadeMetrosPorSegundo;

  /// Dosagem do produto por aplicação, em ml, e distância entre uma
  /// aplicação e a próxima ao longo do trecho, em metros.
  ///
  /// Digitadas pelo administrador nesta versão: o cálculo automático depende
  /// da fórmula do fabricante ("Regra de Negócio - Dosagem e Ciclo
  /// Biológico"), que é executada pela API e ainda não está disponível.
  final double dosagemMl;
  final double distanciaEntreSubpontosMetros;

  /// Quantas aplicações compõem um ciclo completo neste ponto.
  final int quantidadeDeSubpontos;

  /// Aplicador responsável, ou `null` enquanto o ponto está apenas
  /// [EstadoPontoDeAplicacao.enderecada] — atribuir aplicador não é
  /// obrigatório na criação.
  final String? aplicadorId;

  final EstadoPontoDeAplicacao estado;

  /// Agendamento do ciclo vigente (ou do último ciclo, se o ponto já foi
  /// desativado) — `null` enquanto o ponto nunca foi ativado.
  final Agendamento? agendamento;

  /// Estado que o ponto tinha imediatamente antes de [desativar] — só
  /// preenchido enquanto [estado] é [EstadoPontoDeAplicacao.desativado].
  /// Existe só para [reativar] poder devolver o ponto exatamente ao estado
  /// em que estava (GEOPRAG-110), sem precisar de uma segunda fonte de
  /// histórico.
  final EstadoPontoDeAplicacao? estadoAnterior;

  /// Aplicações já registradas neste ponto, da mais antiga para a mais
  /// recente.
  final List<Subponto> subpontos;

  PontoDeAplicacao({
    required this.id,
    required this.nome,
    required this.identificador,
    required this.bairro,
    required this.endereco,
    required this.numeroReferencia,
    required this.descricaoDoTrecho,
    required this.larguraMetros,
    required this.profundidadeMetros,
    required this.velocidadeMetrosPorSegundo,
    required this.dosagemMl,
    required this.distanciaEntreSubpontosMetros,
    required this.quantidadeDeSubpontos,
    required this.estado,
    this.aplicadorId,
    this.agendamento,
    this.estadoAnterior,
    List<Subponto> subpontos = const [],
  }) : subpontos = List.unmodifiable(subpontos) {
    if (estado == EstadoPontoDeAplicacao.ativa && aplicadorId == null) {
      throw const OperacaoNaoPermitidaException(
        'Um ponto ativo precisa de um aplicador responsável.',
      );
    }
  }

  /// Vazão do trecho (m³/s), derivada dos parâmetros hidrológicos brutos.
  ///
  /// Nunca é persistida nem auditada: é sempre recalculada a partir de
  /// [larguraMetros], [profundidadeMetros] e [velocidadeMetrosPorSegundo],
  /// que são a fonte de verdade. Persistir a vazão criaria um segundo valor
  /// capaz de divergir dos três brutos que a originaram.
  double get vazao =>
      larguraMetros * profundidadeMetros * velocidadeMetrosPorSegundo;

  /// Coordenada da primeira aplicação registrada, ou `null` enquanto
  /// nenhuma foi feita. É o que ancora o ponto no mapa: até a primeira
  /// execução em campo, um ponto não tem posição geográfica conhecida.
  Subponto? get primeiraExecucao =>
      subpontos.isEmpty ? null : subpontos.first;

  /// Um ponto em operação que ainda não recebeu nenhuma aplicação — o que
  /// o dashboard destaca como alerta.
  bool get ativoSemRegistro =>
      estado == EstadoPontoDeAplicacao.ativa && subpontos.isEmpty;

  /// Todas as datas do [agendamento] vigente já foram concluídas — a
  /// última recorrência do ciclo foi cumprida (GEOPRAG-110).
  ///
  /// Getter puro: quem decide o que fazer com isso (hoje, transicionar o
  /// ponto para [EstadoPontoDeAplicacao.inativa] na leitura, já que não há
  /// API/job em background nesta versão) é a camada de repository, não a
  /// entidade — ver `AdminPontoDeAplicacaoRepositoryImpl`.
  bool get cicloConcluido =>
      agendamento != null &&
      agendamento!.datas.isNotEmpty &&
      agendamento!.datas.every((d) => d.status == StatusDataAgendada.concluida);

  /// Vincula um aplicador responsável ao ponto, promovendo-o de
  /// [EstadoPontoDeAplicacao.enderecada] para
  /// [EstadoPontoDeAplicacao.direcionada].
  PontoDeAplicacao atribuirAplicador(String novoAplicadorId) {
    return copyWith(
      aplicadorId: novoAplicadorId,
      estado: estado == EstadoPontoDeAplicacao.enderecada
          ? EstadoPontoDeAplicacao.direcionada
          : estado,
    );
  }

  /// Remove o aplicador responsável, devolvendo o ponto a
  /// [EstadoPontoDeAplicacao.enderecada].
  ///
  /// Rejeitado enquanto o ponto está [EstadoPontoDeAplicacao.ativa]: um
  /// ciclo em operação sem responsável deixaria aplicações em campo sem
  /// dono. A mensagem aponta o caminho correto — cancelar a aplicação
  /// química (GEOPRAG-109) — e não "desativar o ponto" (GEOPRAG-110): são
  /// ações diferentes, e desativar aqui seria uma solução mais drástica que
  /// o necessário só para trocar de responsável.
  PontoDeAplicacao desatribuirAplicador() {
    if (estado == EstadoPontoDeAplicacao.ativa) {
      throw const OperacaoNaoPermitidaException(
        'Não é possível desatribuir o aplicador de um ponto ativo. '
        'Cancele a aplicação química em andamento antes.',
      );
    }
    return copyWith(
      limparAplicador: true,
      estado: EstadoPontoDeAplicacao.enderecada,
    );
  }

  /// Ativa o ciclo, aplicando [agendamento] — só a partir de
  /// [EstadoPontoDeAplicacao.direcionada] (primeira ativação) ou
  /// [EstadoPontoDeAplicacao.inativa] (retomada de um ciclo suspenso). Um
  /// agendamento novo sempre substitui o anterior; o histórico de
  /// [subpontos] nunca é tocado aqui.
  PontoDeAplicacao ativar(Agendamento agendamento) {
    if (estado != EstadoPontoDeAplicacao.direcionada &&
        estado != EstadoPontoDeAplicacao.inativa) {
      throw OperacaoNaoPermitidaException(
        'Não é possível ativar um ponto ${estado.name}. Só pontos '
        'direcionados ou inativos podem ser ativados.',
      );
    }
    return copyWith(estado: EstadoPontoDeAplicacao.ativa, agendamento: agendamento);
  }

  /// Retira o ponto de operação — nunca uma exclusão ("Módulo - Gestão de
  /// Aplicações", seção 5). Válido a partir de qualquer estado, exceto de
  /// [EstadoPontoDeAplicacao.desativado] (já desativado).
  ///
  /// Guarda o estado atual em [estadoAnterior] para [reativar] poder
  /// devolver o ponto exatamente a ele depois. Se havia um [agendamento]
  /// vigente, todas as datas ainda [StatusDataAgendada.pendente] viram
  /// [StatusDataAgendada.cancelada] — datas futuras de um ciclo suspenso
  /// não deveriam continuar contando como previstas.
  PontoDeAplicacao desativar() {
    if (estado == EstadoPontoDeAplicacao.desativado) {
      throw const OperacaoNaoPermitidaException(
        'Este ponto já está desativado.',
      );
    }
    return copyWith(
      estado: EstadoPontoDeAplicacao.desativado,
      estadoAnterior: estado,
      agendamento: agendamento == null ? null : _cancelarDatasPendentes(agendamento!),
    );
  }

  /// Devolve o ponto ao estado em que estava antes de [desativar]. Só
  /// válido a partir de [EstadoPontoDeAplicacao.desativado].
  ///
  /// Não recria o agendamento cancelado por [desativar] — reativar um ponto
  /// cujo ciclo tinha datas futuras canceladas devolve um ponto sem
  /// agendamento vigente; um novo ciclo é iniciado por [ativar], com um
  /// agendamento novo.
  PontoDeAplicacao reativar() {
    if (estado != EstadoPontoDeAplicacao.desativado) {
      throw const OperacaoNaoPermitidaException(
        'Só é possível reativar um ponto desativado.',
      );
    }
    final estadoParaRestaurar = estadoAnterior;
    if (estadoParaRestaurar == null) {
      // Defensivo: um ponto desativado por `desativar()` sempre tem
      // `estadoAnterior` preenchido. Só chega aqui um ponto construído já
      // desativado (ex.: fixture de teste ou dado legado) sem essa
      // informação — não há para onde reativar.
      throw const OperacaoNaoPermitidaException(
        'Este ponto não tem um estado anterior registrado para reativar.',
      );
    }
    return copyWith(estado: estadoParaRestaurar, limparEstadoAnterior: true);
  }

  PontoDeAplicacao copyWith({
    String? nome,
    String? bairro,
    String? endereco,
    String? numeroReferencia,
    String? descricaoDoTrecho,
    double? larguraMetros,
    double? profundidadeMetros,
    double? velocidadeMetrosPorSegundo,
    double? dosagemMl,
    double? distanciaEntreSubpontosMetros,
    int? quantidadeDeSubpontos,
    String? aplicadorId,
    EstadoPontoDeAplicacao? estado,
    Agendamento? agendamento,
    EstadoPontoDeAplicacao? estadoAnterior,
    List<Subponto>? subpontos,
    bool limparAplicador = false,
    bool limparEstadoAnterior = false,
  }) {
    return PontoDeAplicacao(
      id: id,
      identificador: identificador,
      nome: nome ?? this.nome,
      bairro: bairro ?? this.bairro,
      endereco: endereco ?? this.endereco,
      numeroReferencia: numeroReferencia ?? this.numeroReferencia,
      descricaoDoTrecho: descricaoDoTrecho ?? this.descricaoDoTrecho,
      larguraMetros: larguraMetros ?? this.larguraMetros,
      profundidadeMetros: profundidadeMetros ?? this.profundidadeMetros,
      velocidadeMetrosPorSegundo:
          velocidadeMetrosPorSegundo ?? this.velocidadeMetrosPorSegundo,
      dosagemMl: dosagemMl ?? this.dosagemMl,
      distanciaEntreSubpontosMetros:
          distanciaEntreSubpontosMetros ?? this.distanciaEntreSubpontosMetros,
      quantidadeDeSubpontos:
          quantidadeDeSubpontos ?? this.quantidadeDeSubpontos,
      aplicadorId: limparAplicador ? null : (aplicadorId ?? this.aplicadorId),
      estado: estado ?? this.estado,
      agendamento: agendamento ?? this.agendamento,
      estadoAnterior: limparEstadoAnterior
          ? null
          : (estadoAnterior ?? this.estadoAnterior),
      subpontos: subpontos ?? this.subpontos,
    );
  }
}

/// Marca como [StatusDataAgendada.cancelada] toda data ainda
/// [StatusDataAgendada.pendente] de [agendamento] — usado por
/// [PontoDeAplicacao.desativar].
Agendamento _cancelarDatasPendentes(Agendamento agendamento) {
  return Agendamento(
    dataInicio: agendamento.dataInicio,
    intervaloDias: agendamento.intervaloDias,
    quantidadeRecorrencias: agendamento.quantidadeRecorrencias,
    datas: [
      for (final data in agendamento.datas)
        data.status == StatusDataAgendada.pendente
            ? data.copyWith(status: StatusDataAgendada.cancelada)
            : data,
    ],
  );
}
