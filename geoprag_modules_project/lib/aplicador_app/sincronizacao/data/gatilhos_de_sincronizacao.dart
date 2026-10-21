import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../src/errors/app_logger.dart';
import '../../local/outbox_dao.dart';
import '../core/monitor_de_conexao.dart';
import '../core/servico_de_sincronizacao.dart';
import 'espera_crescente.dart';

/// Dispara a sincronização (envio da outbox e pull) quando o app abre, volta ao
/// primeiro plano e recupera a conexão (GEOPRAG-190 e 202). O disparo "ao
/// registrar" é do repositório, e só envia.
///
/// Uma sincronização que não se completa (sem rede, servidor fora, sessão
/// expirada) é repetida sozinha, com espera crescente entre as tentativas
/// ([EsperaCrescente]). Qualquer gatilho novo (conexão recuperada, app em
/// primeiro plano) tenta de imediato e substitui a espera marcada.
class GatilhosDeSincronizacao with WidgetsBindingObserver {
  GatilhosDeSincronizacao({
    required ServicoDeSincronizacao servico,
    required OutboxDao outbox,
    required MonitorDeConexao monitor,
    EsperaCrescente? espera,
    Timer Function(Duration espera, void Function() acao)? agendar,
  }) : _servico = servico,
       _outbox = outbox,
       _monitor = monitor,
       _espera = espera ?? EsperaCrescente(),
       _agendar = agendar ?? Timer.new;

  final ServicoDeSincronizacao _servico;
  final OutboxDao _outbox;
  final MonitorDeConexao _monitor;
  final EsperaCrescente _espera;
  final Timer Function(Duration espera, void Function() acao) _agendar;

  bool _ligado = false;
  StreamSubscription<void>? _assinatura;
  Timer? _novaTentativa;

  /// Liga os gatilhos. Primeiro devolve à fila o que ficou `ENVIANDO` porque o
  /// app foi fechado no meio de um envio; só depois passa a ouvir a rede e o
  /// ciclo de vida, para o reenfileiramento nunca pegar um envio já em curso.
  /// Chamar de novo não duplica nada.
  Future<void> iniciar() async {
    if (_ligado) return;
    _ligado = true;
    await _outbox.reenfileirarEmAndamento();
    if (!_ligado) return; // `parar` foi chamado enquanto esperava.
    _assinatura = _monitor.aoConectar.listen((_) => _disparar());
    WidgetsBinding.instance.addObserver(this);
    _disparar();
  }

  Future<void> parar() async {
    _ligado = false;
    WidgetsBinding.instance.removeObserver(this);
    _novaTentativa?.cancel();
    _novaTentativa = null;
    await _assinatura?.cancel();
    _assinatura = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _disparar();
  }

  void _disparar() => unawaited(_sincronizar());

  Future<void> _sincronizar() async {
    _novaTentativa?.cancel();
    _novaTentativa = null;
    var concluida = false;
    try {
      concluida = (await _servico.sincronizar()).concluida;
    } catch (e, stackTrace) {
      AppLogger.error('GatilhosDeSincronizacao', e, stackTrace);
    }
    if (!_ligado) return;
    if (concluida) {
      _espera.reiniciar();
    } else {
      _novaTentativa ??= _agendar(_espera.proxima(), () {
        _novaTentativa = null;
        _disparar();
      });
    }
  }
}
