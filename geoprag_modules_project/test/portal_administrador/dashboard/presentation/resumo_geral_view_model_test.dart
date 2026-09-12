import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/dashboard/core/foco_recente.dart';
import 'package:geoprag_modules/portal_administrador/dashboard/core/resumo_geral.dart';
import 'package:geoprag_modules/portal_administrador/dashboard/presentation/resumo_geral_view_model.dart';

void main() {
  group('FocoRecenteViewModel.fromEntity', () {
    test('mapeia título e status sem alteração', () {
      const entity = FocoRecente(
        titulo: 'Foco Alto - Belchior Alto',
        statusDescricao: 'Status: Equipe a Investigar',
      );

      final viewModel = FocoRecenteViewModel.fromEntity(entity);

      expect(viewModel.titulo, entity.titulo);
      expect(viewModel.statusDescricao, entity.statusDescricao);
    });
  });

  group('ResumoGeralViewModel.fromEntity', () {
    final entity = ResumoGeral(
      lotesAVencer: 2,
      corregosComAplicacaoAtrasada: 4,
      denunciasAbertas: 12,
      atualizacoesEstoque: const ['Lote BTI-001 perto de vencer (5 dias).'],
      ultimasAplicacoes: const ['Bairro Coloninha: Aplicação realizada.'],
      focosRecentes: const [
        FocoRecente(titulo: 'Foco Alto', statusDescricao: 'Recebida'),
      ],
    );

    test('formata estoqueCriticoResumo com a contagem de lotes a vencer', () {
      expect(
        ResumoGeralViewModel.fromEntity(entity).estoqueCriticoResumo,
        '2 lotes a vencer',
      );
    });

    test('formata aplicacoesAtrasadasResumo com a contagem de córregos', () {
      expect(
        ResumoGeralViewModel.fromEntity(entity).aplicacoesAtrasadasResumo,
        '4 córregos',
      );
    });

    test('formata denunciasAbertasTotal como string do total', () {
      expect(
        ResumoGeralViewModel.fromEntity(entity).denunciasAbertasTotal,
        '12',
      );
    });

    test('preserva as listas de atualizações e últimas aplicações sem alteração', () {
      final viewModel = ResumoGeralViewModel.fromEntity(entity);

      expect(viewModel.atualizacoesEstoque, entity.atualizacoesEstoque);
      expect(viewModel.ultimasAplicacoes, entity.ultimasAplicacoes);
    });

    test('mapeia cada FocoRecente da lista para FocoRecenteViewModel', () {
      final viewModel = ResumoGeralViewModel.fromEntity(entity);

      expect(viewModel.focosRecentes, hasLength(1));
      expect(viewModel.focosRecentes.first.titulo, 'Foco Alto');
    });
  });
}
