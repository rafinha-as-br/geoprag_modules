import '../../../src/entities/aplicacao.dart';

/// Registro de aplicações feito em campo, **local-first** (GEOPRAG-190).
///
/// O registro é sempre gravado primeiro no SQLite do aparelho (aplicação e
/// item da outbox, na mesma transação) e só depois enviado ao servidor. Online
/// e offline passam pelo mesmo caminho: a diferença é só se o envio da outbox
/// tem sucesso. Registrar **nunca** exige rede nem token válido.
abstract interface class RegistroDeAplicacaoRepository {
  /// Abre uma aplicação nova (a visita ao ponto), ainda sem subpontos, com
  /// [realizadoEm] (agora, se omitido) e a [localizacao] capturada. Nada vai ao
  /// servidor até o primeiro subponto.
  Future<Aplicacao> iniciarAplicacao({
    required String pontoId,
    required String aplicadorId,
    required String dataAgendadaId,
    required String produtoId,
    required LocalizacaoCapturada localizacao,
    DateTime? realizadoEm,
  });

  /// Acrescenta um subponto à aplicação [aplicacaoId]: grava o subponto e o
  /// item da outbox atomicamente e dispara o envio **sem esperá-lo**. Devolve a
  /// aplicação com o subponto novo.
  ///
  /// Lança [EntidadeNaoEncontradaException] se a aplicação não existe.
  Future<Aplicacao> registrarSubponto({
    required String aplicacaoId,
    required double latitude,
    required double longitude,
    DateTime? realizadoEm,
  });
}
