import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/historico_denuncia.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/denuncia_view_model.dart';

void main() {
  final denuncia = Denuncia(
    id: 'r1',
    lat: -26.9328,
    lng: -48.9554,
    nivelInfestacao: 'Alto',
    descricao: 'Muitos borrachudos na varanda',
    status: 'Recebida',
    dataHora: DateTime(2026, 7, 5, 14, 30),
    denunciante: 'João Silva (Voluntário Belchior)',
    observacoes: 'Muita espuma natural no córrego.',
  );

  final historico = HistoricoDenuncia(
    titulo: 'Criada via App Mobile',
    autor: 'João Silva',
    dataHora: DateTime(1970),
    status: 'Recebida',
  );

  group('DenunciaResumoViewModel.fromEntity', () {
    test('mapeia os campos principais sem alteração', () {
      final viewModel = DenunciaResumoViewModel.fromEntity(denuncia);

      expect(viewModel.id, 'r1');
      expect(viewModel.denunciante, 'João Silva (Voluntário Belchior)');
      expect(viewModel.descricao, 'Muitos borrachudos na varanda');
      expect(viewModel.nivelInfestacao, 'Alto');
      expect(viewModel.status, 'Recebida');
    });

    test('dataFormatada segue o padrão dd/MM/yyyy', () {
      final viewModel = DenunciaResumoViewModel.fromEntity(denuncia);
      expect(viewModel.dataFormatada, '05/07/2026');
    });
  });

  group('HistoricoDenunciaViewModel.fromEntity', () {
    test('mapeia título, autor e status sem alteração', () {
      final viewModel = HistoricoDenunciaViewModel.fromEntity(historico);

      expect(viewModel.titulo, 'Criada via App Mobile');
      expect(viewModel.autor, 'João Silva');
      expect(viewModel.status, 'Recebida');
    });

    test('dataHoraFormatada segue o padrão dd/MM/yyyy às HH:mm', () {
      final item = HistoricoDenuncia(
        titulo: 'Criada via App Mobile',
        autor: 'João Silva',
        dataHora: DateTime(1970),
        status: 'Recebida',
      );
      final itemComDataConhecida = HistoricoDenuncia(
        titulo: item.titulo,
        autor: item.autor,
        dataHora: DateTime(2026, 7, 5, 14, 30),
        status: item.status,
      );

      expect(
        HistoricoDenunciaViewModel.fromEntity(itemComDataConhecida).dataHoraFormatada,
        '05/07/2026 às 14:30',
      );
    });
  });

  group('DenunciaDetalhadaViewModel.fromEntity', () {
    test('mapeia todos os campos e agrega o histórico', () {
      final viewModel = DenunciaDetalhadaViewModel.fromEntity(denuncia, [historico]);

      expect(viewModel.id, 'r1');
      expect(viewModel.lat, denuncia.lat);
      expect(viewModel.lng, denuncia.lng);
      expect(viewModel.observacoes, denuncia.observacoes);
      expect(viewModel.historico, hasLength(1));
      expect(viewModel.historico.first.titulo, 'Criada via App Mobile');
    });

    test('dataHoraFormatada segue o padrão dd/MM/yyyy às HH:mm', () {
      final viewModel = DenunciaDetalhadaViewModel.fromEntity(denuncia, []);
      expect(viewModel.dataHoraFormatada, '05/07/2026 às 14:30');
    });

    test('historico fica vazio quando não há auditoria registrada', () {
      final viewModel = DenunciaDetalhadaViewModel.fromEntity(denuncia, []);
      expect(viewModel.historico, isEmpty);
    });
  });
}
