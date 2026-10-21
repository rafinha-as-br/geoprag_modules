import '../../../src/errors/app_error_messages.dart';
import 'posicao_gps.dart';

/// Por que não foi possível obter a posição do aparelho.
enum MotivoSemPosicao {
  /// O aplicador negou a permissão de localização (dá para pedir de novo).
  permissaoNegada,

  /// A permissão foi negada com "não perguntar de novo": só nas configurações.
  permissaoNegadaParaSempre,

  /// O GPS (serviço de localização) está desligado no aparelho.
  servicoDesligado,

  /// O GPS não deu uma posição a tempo.
  tempoEsgotado,

  /// Falha inesperada ao ler o GPS (plugin, plataforma).
  indisponivel,
}

/// Lançada por [ServicoDeLocalizacao.obterPosicao] quando não há posição.
///
/// Sem posição o app não registra (GEOPRAG-191): quem captura trata esta
/// exceção mostrando [mensagemAmigavel] e deixa o aplicador tentar de novo.
class PosicaoIndisponivelException implements Exception {
  const PosicaoIndisponivelException(this.motivo);

  final MotivoSemPosicao motivo;

  /// Orientação segura para exibir ao aplicador.
  String get mensagemAmigavel => switch (motivo) {
    MotivoSemPosicao.permissaoNegada =>
      AppErrorMessages.localizacaoPermissaoNegada,
    MotivoSemPosicao.permissaoNegadaParaSempre =>
      AppErrorMessages.localizacaoPermissaoNegadaParaSempre,
    MotivoSemPosicao.servicoDesligado =>
      AppErrorMessages.localizacaoServicoDesligado,
    MotivoSemPosicao.tempoEsgotado => AppErrorMessages.localizacaoTempoEsgotado,
    MotivoSemPosicao.indisponivel => AppErrorMessages.localizacaoIndisponivel,
  };

  @override
  String toString() => 'PosicaoIndisponivelException: $motivo';
}

/// Leitura da posição real do aparelho (GEOPRAG-191). Funciona sem rede.
abstract interface class ServicoDeLocalizacao {
  /// Lê a posição atual, pedindo a permissão de localização se ainda não foi
  /// concedida.
  ///
  /// Lança [PosicaoIndisponivelException] se não houver posição (permissão
  /// negada, GPS desligado ou tempo esgotado).
  Future<PosicaoGps> obterPosicao();
}
