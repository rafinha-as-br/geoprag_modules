import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/theme/geoprag_status.dart';

/// Como cada [EstadoPontoDeAplicacao] se apresenta ao usuário: o rótulo do
/// chip e a cor funcional que ele empresta da paleta de status da marca.
///
/// A paleta tem três cores para cinco estados, então a cor sozinha não
/// distingue todos eles — ela separa o ponto em operação (verde) do que
/// ainda depende de uma providência (amarelo) e do que está fora de
/// operação (vermelho). O rótulo é que nomeia o estado exato.
extension EstadoPontoDeAplicacaoApresentacao on EstadoPontoDeAplicacao {
  String get rotulo => switch (this) {
    EstadoPontoDeAplicacao.enderecada => 'Endereçada',
    EstadoPontoDeAplicacao.direcionada => 'Direcionada',
    EstadoPontoDeAplicacao.ativa => 'Ativa',
    EstadoPontoDeAplicacao.inativa => 'Inativa',
    EstadoPontoDeAplicacao.desativado => 'Desativado',
  };

  GeopragStatus get status => switch (this) {
    EstadoPontoDeAplicacao.ativa => GeopragStatus.emDia,
    EstadoPontoDeAplicacao.enderecada ||
    EstadoPontoDeAplicacao.direcionada => GeopragStatus.denuncia,
    EstadoPontoDeAplicacao.inativa ||
    EstadoPontoDeAplicacao.desativado => GeopragStatus.atrasado,
  };
}

/// ViewModel resumida de [PontoDeAplicacao] — o que as listagens do
/// dashboard e do bairro exibem, antes de abrir o detalhe completo.
class PontoDeAplicacaoResumoViewModel {
  final String id;
  final String identificador;
  final String nome;
  final String bairro;
  final EstadoPontoDeAplicacao estado;

  /// Nome do aplicador responsável, ou `null` quando o ponto ainda não foi
  /// direcionado a ninguém.
  final String? aplicadorNome;

  final int execucoesRegistradas;
  final int quantidadeDeSubpontos;

  /// Ponto em operação que ainda não recebeu nenhuma aplicação — o dashboard
  /// destaca esses casos num bloco de alertas.
  final bool ativoSemRegistro;

  const PontoDeAplicacaoResumoViewModel({
    required this.id,
    required this.identificador,
    required this.nome,
    required this.bairro,
    required this.estado,
    required this.aplicadorNome,
    required this.execucoesRegistradas,
    required this.quantidadeDeSubpontos,
    required this.ativoSemRegistro,
  });

  factory PontoDeAplicacaoResumoViewModel.fromEntity(
    PontoDeAplicacao entity, {
    String? aplicadorNome,
  }) {
    return PontoDeAplicacaoResumoViewModel(
      id: entity.id,
      identificador: entity.identificador,
      nome: entity.nome,
      bairro: entity.bairro,
      estado: entity.estado,
      aplicadorNome: aplicadorNome,
      execucoesRegistradas: entity.subpontos.length,
      quantidadeDeSubpontos: entity.quantidadeDeSubpontos,
      ativoSemRegistro: entity.ativoSemRegistro,
    );
  }

  bool get desativado => estado == EstadoPontoDeAplicacao.desativado;
}

/// Cobertura de um bairro no mapa do dashboard: quantos pontos ele tem e
/// como eles estão distribuídos entre os estados.
///
/// O mapa desta versão é um placeholder sem coordenada real — ele mostra a
/// cobertura por bairro, não a posição geográfica de cada ponto (que só
/// existe depois da primeira execução em campo).
class CoberturaDeBairroViewModel {
  final String bairro;
  final int totalDePontos;
  final int pontosAtivos;
  final int pontosComAlerta;

  const CoberturaDeBairroViewModel({
    required this.bairro,
    required this.totalDePontos,
    required this.pontosAtivos,
    required this.pontosComAlerta,
  });

  /// Cor do bairro no mapa: vermelho quando há ponto ativo sem nenhum
  /// registro, verde quando tudo que está em operação já registrou
  /// aplicação, amarelo quando o bairro ainda não tem ponto em operação.
  GeopragStatus get status {
    if (pontosComAlerta > 0) return GeopragStatus.atrasado;
    if (pontosAtivos > 0) return GeopragStatus.emDia;
    return GeopragStatus.denuncia;
  }
}

/// ViewModel detalhada de [PontoDeAplicacao] — a tela de detalhe do ponto.
class PontoDeAplicacaoDetalhadoViewModel {
  final String id;
  final String identificador;
  final String nome;
  final String bairro;
  final String endereco;
  final String numeroReferencia;
  final String descricaoDoTrecho;
  final EstadoPontoDeAplicacao estado;
  final String? aplicadorNome;

  final double larguraMetros;
  final double profundidadeMetros;
  final double velocidadeMetrosPorSegundo;

  /// Derivada dos três parâmetros acima, nunca persistida — ver
  /// [PontoDeAplicacao.vazao].
  final double vazao;

  final double dosagemMl;
  final double distanciaEntreSubpontosMetros;
  final int quantidadeDeSubpontos;
  final List<Subponto> execucoes;

  const PontoDeAplicacaoDetalhadoViewModel({
    required this.id,
    required this.identificador,
    required this.nome,
    required this.bairro,
    required this.endereco,
    required this.numeroReferencia,
    required this.descricaoDoTrecho,
    required this.estado,
    required this.aplicadorNome,
    required this.larguraMetros,
    required this.profundidadeMetros,
    required this.velocidadeMetrosPorSegundo,
    required this.vazao,
    required this.dosagemMl,
    required this.distanciaEntreSubpontosMetros,
    required this.quantidadeDeSubpontos,
    required this.execucoes,
  });

  factory PontoDeAplicacaoDetalhadoViewModel.fromEntity(
    PontoDeAplicacao entity, {
    String? aplicadorNome,
  }) {
    return PontoDeAplicacaoDetalhadoViewModel(
      id: entity.id,
      identificador: entity.identificador,
      nome: entity.nome,
      bairro: entity.bairro,
      endereco: entity.endereco,
      numeroReferencia: entity.numeroReferencia,
      descricaoDoTrecho: entity.descricaoDoTrecho,
      estado: entity.estado,
      aplicadorNome: aplicadorNome,
      larguraMetros: entity.larguraMetros,
      profundidadeMetros: entity.profundidadeMetros,
      velocidadeMetrosPorSegundo: entity.velocidadeMetrosPorSegundo,
      vazao: entity.vazao,
      dosagemMl: entity.dosagemMl,
      distanciaEntreSubpontosMetros: entity.distanciaEntreSubpontosMetros,
      quantidadeDeSubpontos: entity.quantidadeDeSubpontos,
      execucoes: entity.subpontos,
    );
  }
}
