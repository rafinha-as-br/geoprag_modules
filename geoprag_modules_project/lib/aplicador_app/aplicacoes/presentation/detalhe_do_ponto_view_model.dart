import '../../../src/entities/ponto_de_aplicacao.dart';

/// ViewModel de [PontoDeAplicacao] para a tela "Detalhe do Ponto
/// Designado" do aplicador.
class DetalheDoPontoDesignadoViewModel {
  final String id;
  final String identificador;
  final String nome;
  final String bairro;
  final String endereco;
  final String numeroReferencia;
  final String descricaoDoTrecho;
  final EstadoPontoDeAplicacao estado;
  final String dosagemFormatada;
  final double distanciaEntreSubpontosMetros;
  final int quantidadeDeSubpontos;
  final List<Subponto> execucoes;

  const DetalheDoPontoDesignadoViewModel({
    required this.id,
    required this.identificador,
    required this.nome,
    required this.bairro,
    required this.endereco,
    required this.numeroReferencia,
    required this.descricaoDoTrecho,
    required this.estado,
    required this.dosagemFormatada,
    required this.distanciaEntreSubpontosMetros,
    required this.quantidadeDeSubpontos,
    required this.execucoes,
  });

  /// Nenhuma aplicação foi registrada ainda neste ponto — a primeira visita
  /// do aplicador (GEOPRAG-75, parte de revisita). Uma revisita é qualquer
  /// visita depois da primeira.
  bool get primeiraAplicacao => execucoes.isEmpty;

  /// Só pode iniciar uma aplicação em campo enquanto o ciclo está em
  /// operação — [EstadoPontoDeAplicacao.ativa].
  bool get podeIniciarAplicacao => estado == EstadoPontoDeAplicacao.ativa;

  factory DetalheDoPontoDesignadoViewModel.fromEntity(
    PontoDeAplicacao entity,
  ) {
    return DetalheDoPontoDesignadoViewModel(
      id: entity.id,
      identificador: entity.identificador,
      nome: entity.nome,
      bairro: entity.bairro,
      endereco: entity.endereco,
      numeroReferencia: entity.numeroReferencia,
      descricaoDoTrecho: entity.descricaoDoTrecho,
      estado: entity.estado,
      dosagemFormatada: _formatarDosagem(entity.dosagemMl),
      distanciaEntreSubpontosMetros: entity.distanciaEntreSubpontosMetros,
      quantidadeDeSubpontos: entity.quantidadeDeSubpontos,
      execucoes: entity.subpontos,
    );
  }

  static String _formatarDosagem(double dosagem) {
    final valor = dosagem % 1 == 0
        ? dosagem.toStringAsFixed(0)
        : dosagem.toStringAsFixed(1);
    return '$valor ml';
  }
}
