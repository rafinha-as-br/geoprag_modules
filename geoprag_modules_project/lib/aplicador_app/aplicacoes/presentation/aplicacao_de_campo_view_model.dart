import '../../../src/entities/ponto_de_aplicacao.dart';

/// ViewModel de [PontoDeAplicacao] usado no fluxo de campo (informativa →
/// geolocalização → execução) — formata dosagem e endereço, e expõe a
/// distância cadastrada e a distinção primeira aplicação/revisita
/// (GEOPRAG-75, GEOPRAG-74).
class PontoParaAplicacaoViewModel {
  final String id;
  final String nome;
  final String identificador;
  final String enderecoFormatado;
  final String dosagemFormatada;
  final double distanciaEntreSubpontosMetros;
  final int quantidadeDeSubpontos;
  final int execucoesRegistradas;

  const PontoParaAplicacaoViewModel({
    required this.id,
    required this.nome,
    required this.identificador,
    required this.enderecoFormatado,
    required this.dosagemFormatada,
    required this.distanciaEntreSubpontosMetros,
    required this.quantidadeDeSubpontos,
    required this.execucoesRegistradas,
  });

  /// Nenhuma aplicação foi registrada ainda neste ponto — a primeira visita
  /// do aplicador. Uma revisita é qualquer visita depois da primeira.
  bool get primeiraAplicacao => execucoesRegistradas == 0;

  factory PontoParaAplicacaoViewModel.fromEntity(PontoDeAplicacao entity) {
    return PontoParaAplicacaoViewModel(
      id: entity.id,
      nome: entity.nome,
      identificador: entity.identificador,
      enderecoFormatado: '${entity.endereco}, ${entity.numeroReferencia}',
      dosagemFormatada: _formatarDosagem(entity.dosagemMl),
      distanciaEntreSubpontosMetros: entity.distanciaEntreSubpontosMetros,
      quantidadeDeSubpontos: entity.quantidadeDeSubpontos,
      execucoesRegistradas: entity.subpontos.length,
    );
  }

  static String _formatarDosagem(double dosagem) {
    final valor = dosagem % 1 == 0
        ? dosagem.toStringAsFixed(0)
        : dosagem.toStringAsFixed(1);
    return '$valor ml';
  }
}
