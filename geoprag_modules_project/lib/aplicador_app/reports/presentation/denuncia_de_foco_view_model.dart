import '../core/denuncia_de_foco.dart';

/// ViewModel de [DenunciaDeFoco] usada na listagem de denúncias do
/// aplicador (dashboard). Os rótulos estáticos também são reaproveitados
/// pelo formulário de cadastro (`CadastroDoFocoScreen`) para não duplicar a
/// tradução dos enums de domínio em português.
class DenunciaDeFocoViewModel {
  final String id;
  final String titulo;
  final String statusLabel;
  final String dataFormatada;
  final bool atendida;

  const DenunciaDeFocoViewModel({
    required this.id,
    required this.titulo,
    required this.statusLabel,
    required this.dataFormatada,
    required this.atendida,
  });

  factory DenunciaDeFocoViewModel.fromEntity(DenunciaDeFoco entity) {
    return DenunciaDeFocoViewModel(
      id: entity.id,
      titulo:
          'Foco ${labelDoNivel(entity.nivelInfestacao)} - '
          '${entity.localDescricao}',
      statusLabel: labelDoStatus(entity.status),
      dataFormatada: _formatarData(entity.dataRegistro),
      atendida: entity.status == StatusDenunciaDeFoco.atendida,
    );
  }

  static String labelDoNivel(NivelInfestacaoFoco nivel) {
    return switch (nivel) {
      NivelInfestacaoFoco.baixo => 'Baixo',
      NivelInfestacaoFoco.medio => 'Médio',
      NivelInfestacaoFoco.alto => 'Alto',
    };
  }

  static String labelDoStatus(StatusDenunciaDeFoco status) {
    return switch (status) {
      StatusDenunciaDeFoco.recebida => 'Recebida',
      StatusDenunciaDeFoco.atendida => 'Atendida',
    };
  }

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }
}
