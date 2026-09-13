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
class TelaDeAplicacaoEmAndamento extends TelaDeAplicacaoState {
  final PontoParaAplicacaoViewModel ponto;
  final int subpontosRegistrados;
  final bool registrando;

  const TelaDeAplicacaoEmAndamento({
    required this.ponto,
    this.subpontosRegistrados = 0,
    this.registrando = false,
  });

  bool get concluida => subpontosRegistrados >= ponto.quantidadeDeSubpontos;

  TelaDeAplicacaoEmAndamento copyWith({
    int? subpontosRegistrados,
    bool? registrando,
  }) {
    return TelaDeAplicacaoEmAndamento(
      ponto: ponto,
      subpontosRegistrados: subpontosRegistrados ?? this.subpontosRegistrados,
      registrando: registrando ?? this.registrando,
    );
  }
}
