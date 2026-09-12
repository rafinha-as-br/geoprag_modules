import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/reports/core/denuncia_de_foco.dart';
import 'package:geoprag_modules/aplicador_app/reports/presentation/denuncia_de_foco_view_model.dart';

void main() {
  group('DenunciaDeFocoViewModel.fromEntity', () {
    test('monta o título combinando nível de infestação e local', () {
      final entity = DenunciaDeFoco(
        id: '1',
        nivelInfestacao: NivelInfestacaoFoco.alto,
        localDescricao: 'Rua Principal',
        status: StatusDenunciaDeFoco.recebida,
        dataRegistro: DateTime(2026, 7, 5),
      );

      expect(
        DenunciaDeFocoViewModel.fromEntity(entity).titulo,
        'Foco Alto - Rua Principal',
      );
    });

    test('atendida é true quando status == atendida', () {
      final entity = DenunciaDeFoco(
        id: '2',
        nivelInfestacao: NivelInfestacaoFoco.medio,
        localDescricao: 'Remanso',
        status: StatusDenunciaDeFoco.atendida,
        dataRegistro: DateTime(2026, 6, 20),
      );

      final viewModel = DenunciaDeFocoViewModel.fromEntity(entity);
      expect(viewModel.atendida, isTrue);
      expect(viewModel.statusLabel, 'Atendida');
    });

    test('atendida é false quando status == recebida', () {
      final entity = DenunciaDeFoco(
        id: '3',
        nivelInfestacao: NivelInfestacaoFoco.baixo,
        localDescricao: 'Beco',
        status: StatusDenunciaDeFoco.recebida,
        dataRegistro: DateTime(2026, 6, 20),
      );

      final viewModel = DenunciaDeFocoViewModel.fromEntity(entity);
      expect(viewModel.atendida, isFalse);
      expect(viewModel.statusLabel, 'Recebida');
    });

    test('formata a data como dd/MM/yyyy', () {
      final entity = DenunciaDeFoco(
        id: '4',
        nivelInfestacao: NivelInfestacaoFoco.baixo,
        localDescricao: 'Beco',
        status: StatusDenunciaDeFoco.recebida,
        dataRegistro: DateTime(2026, 1, 9),
      );

      expect(DenunciaDeFocoViewModel.fromEntity(entity).dataFormatada, '09/01/2026');
    });
  });

  group('labelDoNivel', () {
    test('traduz todos os valores de NivelInfestacaoFoco', () {
      expect(DenunciaDeFocoViewModel.labelDoNivel(NivelInfestacaoFoco.baixo), 'Baixo');
      expect(DenunciaDeFocoViewModel.labelDoNivel(NivelInfestacaoFoco.medio), 'Médio');
      expect(DenunciaDeFocoViewModel.labelDoNivel(NivelInfestacaoFoco.alto), 'Alto');
    });
  });

  group('labelDoStatus', () {
    test('traduz todos os valores de StatusDenunciaDeFoco', () {
      expect(
        DenunciaDeFocoViewModel.labelDoStatus(StatusDenunciaDeFoco.recebida),
        'Recebida',
      );
      expect(
        DenunciaDeFocoViewModel.labelDoStatus(StatusDenunciaDeFoco.atendida),
        'Atendida',
      );
    });
  });
}
