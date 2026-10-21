import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../src/api/api_client.dart';
import '../src/api/api_client_provider.dart';
import '../src/api/armazenamento_seguro.dart';
import 'aplicacoes/core/registro_de_aplicacao_repository.dart';
import 'aplicacoes/data/registro_de_aplicacao_repository_impl.dart';
import 'local/aplicacao_dao_sqflite.dart';
import 'local/banco_local.dart';
import 'local/outbox_dao.dart';
import 'local/outbox_dao_sqflite.dart';
import 'local/ponto_dao_sqflite.dart';
import 'sincronizacao/core/monitor_de_conexao.dart';
import 'sincronizacao/core/painel_de_sincronizacao.dart';
import 'sincronizacao/core/servico_de_sincronizacao.dart';
import 'sincronizacao/data/cursor_do_pull.dart';
import 'sincronizacao/data/dispositivo_id.dart';
import 'sincronizacao/data/gatilhos_de_sincronizacao.dart';
import 'sincronizacao/data/monitor_de_conexao_connectivity.dart';
import 'sincronizacao/data/painel_de_sincronizacao_impl.dart';
import 'sincronizacao/data/reconciliador_do_pull.dart';
import 'sincronizacao/data/servico_de_sincronizacao_acompanhado.dart';
import 'sincronizacao/data/servico_de_sincronizacao_impl.dart';
import 'sincronizacao/data/ultima_sincronizacao.dart';

/// As instâncias únicas do núcleo offline do App Aplicador (GEOPRAG-190): o
/// banco, a fila (outbox), o serviço de sincronização e o repositório de
/// registro.
///
/// Existem uma vez por processo: duas filas no mesmo banco enviariam o mesmo
/// registro duas vezes, e dois bancos abertos disputariam o arquivo. Por isso
/// o `AplicadorBootstrap` não cria nada disto a cada chamada; abre o núcleo
/// uma vez ([iniciar], em `main`, antes de `runApp`) e entrega sempre as mesmas
/// instâncias.
class NucleoOffline {
  NucleoOffline._({
    required this.banco,
    required this.outbox,
    required this.sincronizacao,
    required this.painel,
    required this.registro,
    required GatilhosDeSincronizacao gatilhos,
  }) : _gatilhos = gatilhos;

  static NucleoOffline? _instancia;
  static Future<NucleoOffline>? _abertura;

  /// O núcleo aberto por [iniciar].
  static NucleoOffline get instancia =>
      _instancia ??
      (throw StateError(
        'O núcleo offline não foi aberto. Chame '
        'AplicadorBootstrap().iniciarNucleoOffline() em main, antes de runApp.',
      ));

  final BancoLocal banco;
  final OutboxDao outbox;
  final ServicoDeSincronizacao sincronizacao;

  /// Indicadores de sincronização para a interface (GEOPRAG-204).
  final PainelDeSincronizacao painel;
  final RegistroDeAplicacaoRepository registro;
  final GatilhosDeSincronizacao _gatilhos;

  /// Abre o banco, monta os serviços e liga os gatilhos de envio (abrir o app,
  /// voltar ao primeiro plano e recuperar a conexão). Chamar de novo devolve o
  /// mesmo núcleo, sem abrir outro banco.
  ///
  /// Os parâmetros existem para os testes (banco em memória, rede falsa); no
  /// app ficam nos padrões: o `ApiClient` compartilhado, o armazenamento seguro
  /// do aparelho e o `connectivity_plus`.
  static Future<NucleoOffline> iniciar({
    ApiClient? api,
    ArmazenamentoSeguro? armazenamento,
    MonitorDeConexao? monitor,
    DatabaseFactory? fabrica,
    String? caminho,
  }) {
    final existente = _abertura;
    if (existente != null) return existente;
    final abertura = _abrir(
      api: api,
      armazenamento: armazenamento,
      monitor: monitor,
      fabrica: fabrica,
      caminho: caminho,
    );
    _abertura = abertura;
    // Uma abertura que falhou não pode travar as próximas tentativas.
    abertura.then<void>(
      (_) {},
      onError: (Object _) {
        if (identical(_abertura, abertura)) _abertura = null;
      },
    );
    return abertura;
  }

  static Future<NucleoOffline> _abrir({
    ApiClient? api,
    ArmazenamentoSeguro? armazenamento,
    MonitorDeConexao? monitor,
    DatabaseFactory? fabrica,
    String? caminho,
  }) async {
    final banco = await BancoLocal.abrir(fabrica: fabrica, caminho: caminho);
    final outbox = OutboxDaoSqflite(banco.db);
    final aplicacoes = AplicacaoDaoSqflite(banco.db);
    final armazenamentoSeguro = armazenamento ?? ArmazenamentoSeguroFlutter();
    final dispositivo = DispositivoId(armazenamentoSeguro);
    // Todos os gatilhos usam o serviço acompanhado: é ele que guarda o horário
    // da última sincronização e avisa a interface (GEOPRAG-204).
    final sincronizacao = ServicoDeSincronizacaoAcompanhado(
      ServicoDeSincronizacaoImpl(
        api: api ?? ApiClientProvider.instancia,
        outbox: outbox,
        reconciliador: ReconciliadorDoPull(
          pontos: PontoDaoSqflite(banco.db),
          outbox: outbox,
          aplicacoes: aplicacoes,
        ),
        dispositivoId: dispositivo.obter,
        cursor: CursorDoPull(armazenamentoSeguro),
      ),
      UltimaSincronizacao(armazenamentoSeguro),
    );
    final gatilhos = GatilhosDeSincronizacao(
      servico: sincronizacao,
      outbox: outbox,
      monitor: monitor ?? MonitorDeConexaoConnectivity(),
    );
    final nucleo = NucleoOffline._(
      banco: banco,
      outbox: outbox,
      sincronizacao: sincronizacao,
      painel: PainelDeSincronizacaoImpl(
        registros: outbox,
        servico: sincronizacao,
      ),
      registro: RegistroDeAplicacaoRepositoryImpl(
        aplicacoes: aplicacoes,
        sincronizacao: sincronizacao,
      ),
      gatilhos: gatilhos,
    );
    try {
      await gatilhos.iniciar();
    } catch (_) {
      // Sem isto, a próxima tentativa abriria um segundo handle do mesmo arquivo.
      await gatilhos.parar();
      await banco.fechar();
      rethrow;
    }
    return _instancia = nucleo;
  }

  /// Desliga os gatilhos, fecha o banco e esquece o núcleo (nos testes).
  @visibleForTesting
  static Future<void> redefinir() async {
    final nucleo = _instancia;
    _instancia = null;
    _abertura = null;
    if (nucleo == null) return;
    await nucleo._gatilhos.parar();
    await nucleo.banco.fechar();
  }
}
