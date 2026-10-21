import 'dart:async';

import 'package:geoprag_modules/aplicador_app/local/local.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/sincronizacao.dart';
import 'package:geoprag_modules/src/api/api_client.dart';
import 'package:geoprag_modules/src/services/gerador_de_id.dart';
import 'package:mocktail/mocktail.dart';

import '../local/apoio_do_banco.dart';

class ApiFalsa extends Mock implements ApiClient {}

class ServicoFalso extends Mock implements ServicoDeSincronizacao {}

/// Gerador de ids previsíveis: `id-1`, `id-2`…
class GeradorSequencial implements GeradorDeId {
  int _n = 0;

  @override
  String gerar() => 'id-${++_n}';
}

/// [MonitorDeConexao] controlado pelo teste.
class MonitorFalso implements MonitorDeConexao {
  final StreamController<void> controlador = StreamController<void>.broadcast();

  @override
  Stream<void> get aoConectar => controlador.stream;

  void conectar() => controlador.add(null);
}

/// Resposta de `POST /sync/aplicacoes` com um resultado por item.
Map<String, Object?> respostaDoLote(List<Map<String, Object?>> resultados) => {
  'recebidoEm': '2026-10-21T10:00:00Z',
  'resultados': resultados,
};

Map<String, Object?> criado(String id) => {'id': id, 'status': 'CRIADO'};

Map<String, Object?> duplicado(String id) => {'id': id, 'status': 'DUPLICADO'};

Map<String, Object?> rejeitado(String id, {String? codigo, String? motivo}) => {
  'id': id,
  'status': 'REJEITADO',
  'codigo': ?codigo,
  'motivo': ?motivo,
};

/// Grava uma aplicação com um subponto e o item `PENDENTE` dele na outbox.
Future<void> enfileira(
  AplicacaoDao aplicacoes,
  String subpontoId, {
  String pontoId = 'ponto-1',
  int minutos = 0,
}) async {
  final subponto = subpontoDeTeste(subpontoId);
  final aplicacao = aplicacaoDeTeste(
    'app-$subpontoId',
    pontoId: pontoId,
    subpontos: [subponto],
  );
  await aplicacoes.gravarComOutbox(aplicacao, [
    itemDoSubponto(
      aplicacao,
      subponto,
      criadoEm: agoraDeTeste.add(Duration(minutes: minutos)),
    ),
  ]);
}

/// Stub de `ApiClient.post` para qualquer lote.
When<Future<Object?>> postDoLote(ApiFalsa api) =>
    when(() => api.post(any(), corpo: any(named: 'corpo')));

/// Corpos (lotes) enviados a `POST /sync/aplicacoes`, na ordem.
List<Map<String, dynamic>> lotesEnviados(ApiFalsa api) => [
  for (final chamada in verify(
    () => api.post('/sync/aplicacoes', corpo: captureAny(named: 'corpo')),
  ).captured)
    chamada as Map<String, dynamic>,
];
