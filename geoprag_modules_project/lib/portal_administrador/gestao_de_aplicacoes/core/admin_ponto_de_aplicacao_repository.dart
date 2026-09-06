import '../../../src/entities/ponto_de_aplicacao.dart';

/// Contrato de acesso aos Pontos de Aplicação pelo Portal Administrador.
///
/// Prefixo `Admin` porque `aplicador_app/application_points` já expõe um
/// `PontoDeAplicacaoRepository` — o do aplicador enxerga só o ponto atribuído
/// a ele, este enxerga todos os pontos do município (mesma convenção de
/// `AdminNavigator`/`AdminAccount`).
///
/// As ações que mudam o ciclo de vida de um ponto (ativar, agendar,
/// desativar/reativar, atribuir aplicador, cancelar) entram aqui na issue de
/// ações individuais da sprint — as invariantes que elas precisam respeitar
/// já vivem no domínio, em [PontoDeAplicacao].
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class AdminPontoDeAplicacaoRepository {
  Future<List<PontoDeAplicacao>> listar();

  Future<List<PontoDeAplicacao>> listarPorBairro(String bairro);

  /// Lança `EntidadeNaoEncontradaException` se o [id] não existir.
  Future<PontoDeAplicacao> buscarPorId(String id);

  /// Cadastra um ponto novo. Nasce em
  /// [EstadoPontoDeAplicacao.enderecada] quando [aplicadorId] é `null`, ou
  /// em [EstadoPontoDeAplicacao.direcionada] quando um responsável já é
  /// escolhido na criação — nunca em operação, e nunca com coordenada
  /// (georreferenciamento só acontece em campo).
  Future<PontoDeAplicacao> criar({
    required String nome,
    required String bairro,
    required String endereco,
    required String numeroReferencia,
    required String descricaoDoTrecho,
    required double larguraMetros,
    required double profundidadeMetros,
    required double velocidadeMetrosPorSegundo,
    required double dosagemMl,
    required double distanciaEntreSubpontosMetros,
    required int quantidadeDeSubpontos,
    String? aplicadorId,
  });
}
