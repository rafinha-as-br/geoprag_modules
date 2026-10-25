import 'dart:async';

import '../../../src/api/sync/sync_mappers.dart';
import '../../../src/entities/aplicacao.dart';
import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/entities/produto.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/services/gerador_de_id.dart';
import '../../local/aplicacao_dao.dart';
import '../../local/item_da_outbox.dart';
import '../../local/produto_dao.dart';
import '../../sincronizacao/core/servico_de_sincronizacao.dart';
import '../core/registro_de_aplicacao_repository.dart';

/// [RegistroDeAplicacaoRepository] sobre o SQLite do aparelho.
///
/// Só toca os DAOs e o [ServicoDeSincronizacao]: não conhece o
/// `ApiClient` nem o token. Uma falha do envio (rede, servidor, sessão) nunca
/// chega a quem registrou; o item continua na outbox, `PENDENTE`.
class RegistroDeAplicacaoRepositoryImpl
    implements RegistroDeAplicacaoRepository {
  /// [agora] e [gerador] existem para os testes fixarem relógio e ids.
  RegistroDeAplicacaoRepositoryImpl({
    required AplicacaoDao aplicacoes,
    required ServicoDeSincronizacao sincronizacao,
    required ProdutoDao produtos,
    GeradorDeId? gerador,
    DateTime Function()? agora,
  }) : _aplicacoes = aplicacoes,
       _sincronizacao = sincronizacao,
       _produtos = produtos,
       _gerador = gerador ?? GeradorDeIdUuid(),
       _agora = agora ?? DateTime.now;

  final AplicacaoDao _aplicacoes;
  final ServicoDeSincronizacao _sincronizacao;
  final ProdutoDao _produtos;
  final GeradorDeId _gerador;
  final DateTime Function() _agora;

  @override
  Future<List<Produto>> listarProdutos() => _produtos.listar();

  @override
  Future<Aplicacao> iniciarAplicacao({
    required String pontoId,
    required String aplicadorId,
    required String dataAgendadaId,
    required String produtoId,
    required LocalizacaoCapturada localizacao,
    DateTime? realizadoEm,
  }) async {
    final aplicacao = Aplicacao.nova(
      gerador: _gerador,
      pontoId: pontoId,
      aplicadorId: aplicadorId,
      dataAgendadaId: dataAgendadaId,
      produtoId: produtoId,
      realizadoEm: realizadoEm ?? _agora(),
      localizacao: localizacao,
    );
    await _aplicacoes.gravarComOutbox(aplicacao, const []);
    return aplicacao;
  }

  @override
  Future<Aplicacao> registrarSubponto({
    required String aplicacaoId,
    required double latitude,
    required double longitude,
    DateTime? realizadoEm,
  }) async {
    final atual = await _aplicacoes.buscarPorId(aplicacaoId);
    if (atual == null) {
      throw EntidadeNaoEncontradaException(
        'Aplicação "$aplicacaoId" não encontrada.',
      );
    }
    final agora = _agora();
    final subponto = Subponto.novo(
      gerador: _gerador,
      latitude: latitude,
      longitude: longitude,
      realizadoEm: realizadoEm ?? agora,
      registradoEm: agora,
    );
    final aplicacao = atual.comSubponto(subponto);
    final registro = SyncMappers.itensDaAplicacao(
      aplicacao,
    ).firstWhere((item) => item.id == subponto.id);
    await _aplicacoes.gravarComOutbox(aplicacao, [
      ItemDaOutbox.paraSubponto(registro, criadoEm: agora),
    ]);
    _dispararEnvio();
    return aplicacao;
  }

  /// Dispara o envio sem esperá-lo e sem deixar a falha dele escapar.
  void _dispararEnvio() => unawaited(_enviar());

  Future<void> _enviar() async {
    try {
      await _sincronizacao.enviarPendentes();
    } catch (e, stackTrace) {
      AppLogger.error('RegistroDeAplicacaoRepositoryImpl', e, stackTrace);
    }
  }
}
