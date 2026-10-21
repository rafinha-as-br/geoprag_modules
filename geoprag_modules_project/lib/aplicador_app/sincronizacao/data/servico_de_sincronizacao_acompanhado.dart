import 'dart:async';

import '../../../src/errors/app_logger.dart';
import '../core/resultado_da_sincronizacao.dart';
import '../core/servico_de_sincronizacao.dart';
import 'ultima_sincronizacao.dart';

/// [ServicoDeSincronizacao] que acompanha o serviço de verdade (GEOPRAG-204):
/// guarda o horário de cada sincronização completa bem-sucedida e avisa
/// ([aoMudar]) quando um envio ou uma sincronização termina, para a interface
/// atualizar os indicadores sem o usuário fazer nada.
///
/// Todos os gatilhos (abrir o app, voltar ao primeiro plano, recuperar a
/// conexão, registrar) devem usar esta instância, para que nenhuma
/// sincronização fique sem registro.
class ServicoDeSincronizacaoAcompanhado implements ServicoDeSincronizacao {
  /// [agora] é o relógio do horário guardado; injetável para os testes.
  ServicoDeSincronizacaoAcompanhado(
    this._servico,
    this._ultima, {
    DateTime Function()? agora,
  }) : _agora = agora ?? DateTime.now;

  final ServicoDeSincronizacao _servico;
  final UltimaSincronizacao _ultima;
  final DateTime Function() _agora;
  final StreamController<void> _mudancas = StreamController<void>.broadcast();

  /// Dispara quando um envio ou uma sincronização termina, com ou sem sucesso.
  Stream<void> get aoMudar => _mudancas.stream;

  Future<DateTime?> ultimaBemSucedida() => _ultima.ler();

  @override
  Future<void> enviarPendentes() async {
    try {
      await _servico.enviarPendentes();
    } finally {
      _avisar();
    }
  }

  @override
  Future<ResultadoDaSincronizacao> sincronizar() async {
    try {
      final resultado = await _servico.sincronizar();
      if (resultado.concluida) await _guardarHorario();
      return resultado;
    } finally {
      _avisar();
    }
  }

  /// Não conseguir guardar o horário não pode transformar uma sincronização que
  /// deu certo em falha.
  Future<void> _guardarHorario() async {
    try {
      await _ultima.gravar(_agora());
    } catch (e, stackTrace) {
      AppLogger.error('ServicoDeSincronizacaoAcompanhado', e, stackTrace);
    }
  }

  void _avisar() => _mudancas.add(null);
}
