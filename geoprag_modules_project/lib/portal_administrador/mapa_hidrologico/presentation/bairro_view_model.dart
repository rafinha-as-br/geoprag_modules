import '../core/bairro.dart';
import '../core/corrego.dart';
import 'corrego_view_model.dart';

/// ViewModel resumida de [Bairro] — usada na listagem de bairros
/// monitorados e nos pins/alertas do mapa geral.
class BairroResumoViewModel {
  final String id;
  final String nome;
  final String status;
  final int diasSemAplicacao;

  const BairroResumoViewModel({
    required this.id,
    required this.nome,
    required this.status,
    required this.diasSemAplicacao,
  });

  factory BairroResumoViewModel.fromEntity(Bairro entity) {
    return BairroResumoViewModel(
      id: entity.id,
      nome: entity.nome,
      status: entity.status,
      diasSemAplicacao: entity.diasSemAplicacao,
    );
  }
}

/// ViewModel detalhada de [Bairro] — status agregado mais os córregos que o
/// atravessam (agregado via
/// `CorregoRepository.listarCorregosDoBairro`).
class BairroDetalhadoViewModel {
  final String id;
  final String nome;
  final String status;
  final int diasSemAplicacao;
  final List<CorregoResumoViewModel> corregos;

  const BairroDetalhadoViewModel({
    required this.id,
    required this.nome,
    required this.status,
    required this.diasSemAplicacao,
    required this.corregos,
  });

  factory BairroDetalhadoViewModel.fromEntity(
    Bairro entity,
    List<Corrego> corregos,
  ) {
    return BairroDetalhadoViewModel(
      id: entity.id,
      nome: entity.nome,
      status: entity.status,
      diasSemAplicacao: entity.diasSemAplicacao,
      corregos: corregos.map(CorregoResumoViewModel.fromEntity).toList(),
    );
  }
}
