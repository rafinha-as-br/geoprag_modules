/// Um evento de aplicação de produto biológico, registrado pelo aplicador
/// em campo no `aplicador_app`.
///
/// Entidade compartilhada entre `aplicador_app` e `portal_administrador`
/// (este último a lê, sem redefinir, para exibição no Mapa Hidrológico —
/// ver `portal_administrador/mapa_hidrologico/core/aplicacao_mapa_repository.dart`).
/// Modelagem completa (CRUD, histórico) permanece de responsabilidade do
/// módulo `aplicador_app/applications`.
class Aplicacao {
  final String id;
  final DateTime data;
  final double lat;
  final double lng;
  final double dosagem;
  final String aplicadorId;

  const Aplicacao({
    required this.id,
    required this.data,
    required this.lat,
    required this.lng,
    required this.dosagem,
    required this.aplicadorId,
  });
}
