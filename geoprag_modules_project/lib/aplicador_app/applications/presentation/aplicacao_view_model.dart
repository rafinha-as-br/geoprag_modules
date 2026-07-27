import '../../../src/entities/aplicacao.dart';

/// ViewModel de [Aplicacao] usado nas telas de execução da aplicação —
/// formata dosagem, data e localização do ponto para exibição.
class AplicacaoAtualViewModel {
  final String id;
  final String dataFormatada;
  final String dosagemFormatada;
  final String localizacaoFormatada;
  final String aplicadorId;

  const AplicacaoAtualViewModel({
    required this.id,
    required this.dataFormatada,
    required this.dosagemFormatada,
    required this.localizacaoFormatada,
    required this.aplicadorId,
  });

  factory AplicacaoAtualViewModel.fromEntity(Aplicacao entity) {
    return AplicacaoAtualViewModel(
      id: entity.id,
      dataFormatada: _formatarData(entity.data),
      dosagemFormatada: _formatarDosagem(entity.dosagem),
      localizacaoFormatada:
          '${entity.lat.toStringAsFixed(4)}, ${entity.lng.toStringAsFixed(4)}',
      aplicadorId: entity.aplicadorId,
    );
  }

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  static String _formatarDosagem(double dosagem) {
    final valor = dosagem % 1 == 0
        ? dosagem.toStringAsFixed(0)
        : dosagem.toStringAsFixed(1);
    return '$valor ml';
  }
}
