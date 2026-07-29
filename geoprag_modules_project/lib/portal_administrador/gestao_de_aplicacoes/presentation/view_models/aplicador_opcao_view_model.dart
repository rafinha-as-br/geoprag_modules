import '../../../gestao_de_aplicadores/core/aplicador.dart';

/// Opção de aplicador para o dropdown de atribuição (criação e detalhe de
/// ponto) — acoplamento com `gestao_de_aplicadores` já estabelecido neste
/// módulo (ver `PontoDeAplicacaoDetalheCubit`/`CriarPontoCubit`).
class AplicadorOpcaoViewModel {
  final String id;
  final String nome;

  const AplicadorOpcaoViewModel({required this.id, required this.nome});

  factory AplicadorOpcaoViewModel.fromEntity(Aplicador aplicador) {
    return AplicadorOpcaoViewModel(id: aplicador.id, nome: aplicador.nome);
  }
}
