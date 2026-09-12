import '../core/corrego.dart';

/// ViewModel resumida de [Corrego] — usada nas listas de córregos dentro do
/// detalhe de um [Bairro].
class CorregoResumoViewModel {
  final String id;
  final String nome;
  final String bairro;

  const CorregoResumoViewModel({
    required this.id,
    required this.nome,
    required this.bairro,
  });

  factory CorregoResumoViewModel.fromEntity(Corrego entity) {
    return CorregoResumoViewModel(
      id: entity.id,
      nome: entity.nome,
      bairro: entity.bairro,
    );
  }
}

/// ViewModel detalhada de [Corrego] — medições físicas completas exibidas na
/// tela de visualização de um córrego específico.
class CorregoDetalhadoViewModel {
  final String id;
  final String nome;
  final String bairro;
  final double largura;
  final double profundidade;
  final double velocidade;

  const CorregoDetalhadoViewModel({
    required this.id,
    required this.nome,
    required this.bairro,
    required this.largura,
    required this.profundidade,
    required this.velocidade,
  });

  factory CorregoDetalhadoViewModel.fromEntity(Corrego entity) {
    return CorregoDetalhadoViewModel(
      id: entity.id,
      nome: entity.nome,
      bairro: entity.bairro,
      largura: entity.largura,
      profundidade: entity.profundidade,
      velocidade: entity.velocidade,
    );
  }
}
