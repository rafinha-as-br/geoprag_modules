import '../../../src/entities/ponto_de_aplicacao.dart';

/// ViewModel resumida de [PontoDeAplicacao] para a lista "Meus Pontos de
/// Aplicação" do aplicador.
class PontoDoAplicadorResumoViewModel {
  final String id;
  final String identificador;
  final String nome;
  final String bairro;
  final EstadoPontoDeAplicacao estado;
  final String dosagemFormatada;
  final int execucoesRegistradas;
  final int quantidadeDeSubpontos;

  /// Ponto em operação que ainda não recebeu nenhuma aplicação — o que a
  /// ordenação por urgência da lista destaca primeiro.
  final bool ativoSemRegistro;

  const PontoDoAplicadorResumoViewModel({
    required this.id,
    required this.identificador,
    required this.nome,
    required this.bairro,
    required this.estado,
    required this.dosagemFormatada,
    required this.execucoesRegistradas,
    required this.quantidadeDeSubpontos,
    required this.ativoSemRegistro,
  });

  factory PontoDoAplicadorResumoViewModel.fromEntity(PontoDeAplicacao entity) {
    return PontoDoAplicadorResumoViewModel(
      id: entity.id,
      identificador: entity.identificador,
      nome: entity.nome,
      bairro: entity.bairro,
      estado: entity.estado,
      dosagemFormatada: _formatarDosagem(entity.dosagemMl),
      execucoesRegistradas: entity.subpontos.length,
      quantidadeDeSubpontos: entity.quantidadeDeSubpontos,
      ativoSemRegistro: entity.ativoSemRegistro,
    );
  }

  static String _formatarDosagem(double dosagem) {
    final valor = dosagem % 1 == 0
        ? dosagem.toStringAsFixed(0)
        : dosagem.toStringAsFixed(1);
    return '$valor ml';
  }
}

/// Ordena pontos do aplicador por urgência (mais urgente primeiro): ponto
/// ativo sem nenhum registro à frente de qualquer outro, seguido por ponto
/// em operação com histórico, depois direcionado (aguardando ativação do
/// administrador) e por fim inativo. Pontos desativados nunca chegam aqui —
/// já são filtrados no repository.
int compararPontosDoAplicadorPorUrgencia(
  PontoDeAplicacao a,
  PontoDeAplicacao b,
) {
  final diferenca = _prioridadeDeUrgencia(a) - _prioridadeDeUrgencia(b);
  if (diferenca != 0) return diferenca;
  return a.nome.compareTo(b.nome);
}

int _prioridadeDeUrgencia(PontoDeAplicacao ponto) {
  if (ponto.ativoSemRegistro) return 0;
  if (ponto.estado == EstadoPontoDeAplicacao.ativa) return 1;
  if (ponto.estado == EstadoPontoDeAplicacao.direcionada) return 2;
  return 3;
}
