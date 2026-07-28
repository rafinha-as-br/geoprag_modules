import '../core/foco_recente.dart';
import '../core/resumo_geral.dart';

/// ViewModel de [FocoRecente] — dados de exibição de um foco recente listado
/// no card de Visão Geográfica do Dashboard.
class FocoRecenteViewModel {
  final String titulo;
  final String statusDescricao;

  const FocoRecenteViewModel({
    required this.titulo,
    required this.statusDescricao,
  });

  factory FocoRecenteViewModel.fromEntity(FocoRecente entity) {
    return FocoRecenteViewModel(
      titulo: entity.titulo,
      statusDescricao: entity.statusDescricao,
    );
  }
}

/// ViewModel de [ResumoGeral] — formata os KPIs agregados nas legendas
/// exibidas pelos cartões do Dashboard geral do Portal Administrador.
class ResumoGeralViewModel {
  final String estoqueCriticoResumo;
  final String aplicacoesAtrasadasResumo;
  final String denunciasAbertasTotal;
  final List<String> atualizacoesEstoque;
  final List<String> ultimasAplicacoes;
  final List<FocoRecenteViewModel> focosRecentes;

  const ResumoGeralViewModel({
    required this.estoqueCriticoResumo,
    required this.aplicacoesAtrasadasResumo,
    required this.denunciasAbertasTotal,
    required this.atualizacoesEstoque,
    required this.ultimasAplicacoes,
    required this.focosRecentes,
  });

  factory ResumoGeralViewModel.fromEntity(ResumoGeral entity) {
    return ResumoGeralViewModel(
      estoqueCriticoResumo: '${entity.lotesAVencer} lotes a vencer',
      aplicacoesAtrasadasResumo:
          '${entity.corregosComAplicacaoAtrasada} córregos',
      denunciasAbertasTotal: '${entity.denunciasAbertas}',
      atualizacoesEstoque: entity.atualizacoesEstoque,
      ultimasAplicacoes: entity.ultimasAplicacoes,
      focosRecentes: entity.focosRecentes
          .map(FocoRecenteViewModel.fromEntity)
          .toList(),
    );
  }
}
