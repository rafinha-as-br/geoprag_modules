import '../core/aplicador.dart';
import '../core/atuacao_aplicador.dart';

/// ViewModel resumida de [Aplicador] — usada na listagem, antes de abrir o
/// detalhe completo.
class AplicadorResumoViewModel {
  final String id;
  final String nome;
  final String bairro;
  final String status;

  const AplicadorResumoViewModel({
    required this.id,
    required this.nome,
    required this.bairro,
    required this.status,
  });

  factory AplicadorResumoViewModel.fromEntity(Aplicador entity) {
    return AplicadorResumoViewModel(
      id: entity.id,
      nome: entity.nome,
      bairro: entity.bairro,
      status: entity.status,
    );
  }
}

class AtuacaoAplicadorViewModel {
  final AtuacaoAplicadorTipo tipo;
  final String titulo;
  final String subtitulo;
  final String valor;

  const AtuacaoAplicadorViewModel({
    required this.tipo,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
  });

  factory AtuacaoAplicadorViewModel.fromEntity(AtuacaoAplicador entity) {
    return AtuacaoAplicadorViewModel(
      tipo: entity.tipo,
      titulo: entity.titulo,
      subtitulo: entity.subtitulo,
      valor: entity.valor,
    );
  }
}

/// ViewModel detalhada de [Aplicador] — dados de perfil completos mais o
/// histórico de atuações (agregado de outra fonte, ver
/// [AplicadorRepository.buscarHistorico]).
class AplicadorDetalhadoViewModel {
  final String nome;
  final String cpf;
  final String telefone;
  final String endereco;
  final String status;
  final List<AtuacaoAplicadorViewModel> historico;

  const AplicadorDetalhadoViewModel({
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.endereco,
    required this.status,
    required this.historico,
  });

  factory AplicadorDetalhadoViewModel.fromEntity(
    Aplicador entity,
    List<AtuacaoAplicador> historico,
  ) {
    return AplicadorDetalhadoViewModel(
      nome: entity.nome,
      cpf: entity.cpf,
      telefone: entity.telefone,
      endereco: entity.endereco,
      status: entity.status,
      historico: historico.map(AtuacaoAplicadorViewModel.fromEntity).toList(),
    );
  }
}
