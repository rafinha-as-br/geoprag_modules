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
  /// dono. Desative o ponto antes de desatribuir.
  PontoDeAplicacao desatribuirAplicador() {
    if (estado == EstadoPontoDeAplicacao.ativa) {
      throw const OperacaoNaoPermitidaException(
        'Não é possível desatribuir o aplicador de um ponto ativo. '
        'Desative o ponto antes.',
      );
    }
    return copyWith(
      limparAplicador: true,
      estado: EstadoPontoDeAplicacao.enderecada,
    );
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
    List<Subponto>? subpontos,
    bool limparAplicador = false,
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
      subpontos: subpontos ?? this.subpontos,
    );
  }
}
