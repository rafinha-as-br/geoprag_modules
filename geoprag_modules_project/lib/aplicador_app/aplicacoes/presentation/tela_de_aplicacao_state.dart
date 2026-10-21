import 'aplicacao_de_campo_view_model.dart';

sealed class TelaDeAplicacaoState {
  const TelaDeAplicacaoState();
}

class TelaDeAplicacaoLoading extends TelaDeAplicacaoState {
  const TelaDeAplicacaoLoading();
}

class TelaDeAplicacaoError extends TelaDeAplicacaoState {
  final String message;
  const TelaDeAplicacaoError(this.message);
}

/// [subpontosRegistrados] conta quantos subpontos foram registrados nesta
/// sessão de aplicação — um contador simples (GEOPRAG-111), sem validação
/// de ordem/posição esperada. Ao atingir [PontoParaAplicacaoViewModel.
/// quantidadeDeSubpontos], [concluida] fica `true`.
///
/// [mensagemDeErro] é a orientação quando o último registro não aconteceu por
/// falta de posição do GPS (GEOPRAG-191); o aplicador pode tentar de novo.
class TelaDeAplicacaoEmAndamento extends TelaDeAplicacaoState {
  final PontoParaAplicacaoViewModel ponto;
  final int subpontosRegistrados;
  final bool registrando;
  final String? mensagemDeErro;

  const TelaDeAplicacaoEmAndamento({
    required this.ponto,
    this.subpontosRegistrados = 0,
    this.registrando = false,
    this.mensagemDeErro,
  });

  bool get concluida => subpontosRegistrados >= ponto.quantidadeDeSubpontos;

  /// [mensagemDeErro] sempre é substituída pelo valor passado (`null` limpa).
  TelaDeAplicacaoEmAndamento copyWith({
    int? subpontosRegistrados,
    bool? registrando,
    String? mensagemDeErro,
  }) {
    return TelaDeAplicacaoEmAndamento(
      ponto: ponto,
      subpontosRegistrados: subpontosRegistrados ?? this.subpontosRegistrados,
      registrando: registrando ?? this.registrando,
      mensagemDeErro: mensagemDeErro,
    );
  }
}
