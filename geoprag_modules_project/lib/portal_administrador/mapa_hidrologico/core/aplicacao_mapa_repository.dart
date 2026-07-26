import '../../../aplicador_app/applications/core/aplicacao.dart';

/// Contrato mínimo de leitura de uma [Aplicacao] (evento de aplicação de
/// inseticida registrado pelo `aplicador_app`) para exibição na tela de
/// visualização de aplicação do Mapa Hidrológico.
///
/// Decisão de arquitetura: `Aplicacao` é modelada em
/// `aplicador_app/applications/core/aplicacao.dart` e é lida diretamente
/// aqui (leitura cross-portal), em vez de redefinida — é o MESMO conceito de
/// domínio, não uma duplicação. A modelagem completa do repositório de
/// Aplicacao (CRUD, histórico, etc.) permanece de responsabilidade do módulo
/// `aplicador_app/applications`; este contrato é intencionalmente escopado
/// apenas à necessidade pontual desta tela (buscar uma aplicação por id para
/// exibir no mapa), por isso vive com um nome próprio
/// ([AplicacaoMapaRepository]) e não como um `AplicacaoRepository` genérico
/// — evitaria colisão de nome quando o módulo `applications` ganhar seu
/// próprio repositório completo (tarefa já mapeada em outro módulo).
///
/// TODO(GEOPRAG-24): contrato real do endpoint ainda não validado com o
/// backend.
abstract class AplicacaoMapaRepository {
  Future<Aplicacao> buscarPorId(String id);
}
