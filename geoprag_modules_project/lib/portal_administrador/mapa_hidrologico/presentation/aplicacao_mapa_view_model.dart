import '../../../aplicador_app/applications/core/aplicacao.dart';

/// ViewModel de leitura de uma [Aplicacao] (evento de aplicação de
/// inseticida) exibida na tela de visualização de aplicação do Mapa
/// Hidrológico. Ver `core/aplicacao_mapa_repository.dart` para a decisão de
/// arquitetura sobre a leitura cross-portal da entidade [Aplicacao].
class AplicacaoMapaViewModel {
  final String id;
  final DateTime data;
  final double lat;
  final double lng;
  final double dosagem;
  final String aplicadorId;

  const AplicacaoMapaViewModel({
    required this.id,
    required this.data,
    required this.lat,
    required this.lng,
    required this.dosagem,
    required this.aplicadorId,
  });

  factory AplicacaoMapaViewModel.fromEntity(Aplicacao entity) {
    return AplicacaoMapaViewModel(
      id: entity.id,
      data: entity.data,
      lat: entity.lat,
      lng: entity.lng,
      dosagem: entity.dosagem,
      aplicadorId: entity.aplicadorId,
    );
  }
}
