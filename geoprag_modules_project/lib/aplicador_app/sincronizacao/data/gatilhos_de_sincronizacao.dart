import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../src/errors/app_logger.dart';
import '../../local/outbox_dao.dart';
import '../core/monitor_de_conexao.dart';
import '../core/servico_de_sincronizacao.dart';

/// Dispara o envio da outbox quando o app abre, volta ao primeiro plano e
/// recupera a conexão (GEOPRAG-190). O disparo "ao registrar" é do repositório.
class GatilhosDeSincronizacao with WidgetsBindingObserver {
  GatilhosDeSincronizacao({
    required ServicoDeSincronizacao servico,
    required OutboxDao outbox,
    required MonitorDeConexao monitor,
  }) : _servico = servico,
       _outbox = outbox,
       _monitor = monitor;

  final ServicoDeSincronizacao _servico;
  final OutboxDao _outbox;
  final MonitorDeConexao _monitor;

  bool _ligado = false;
  StreamSubscription<void>? _assinatura;

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
    await _assinatura?.cancel();
    _assinatura = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _disparar();
  }

  void _disparar() => unawaited(_enviar());

  Future<void> _enviar() async {
    try {
      await _servico.enviarPendentes();
    } catch (e, stackTrace) {
      AppLogger.error('GatilhosDeSincronizacao', e, stackTrace);
    }
  }
}
