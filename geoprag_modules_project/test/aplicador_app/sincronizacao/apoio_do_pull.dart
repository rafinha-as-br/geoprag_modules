import 'package:geoprag_modules/src/api/sync/pull_dtos.dart';

/// `PontoDoAplicador` no formato do `GET /sync/pull`.
///
/// Por padrão o ponto tem duas datas: `<id>-d1` pendente e `<id>-d2` concluída,
/// e exige 3 subpontos por aplicação (como o `pontoDeTeste` do banco).
Map<String, dynamic> pontoDoPull(
  String id, {
  String nome = 'Córrego Gasparinho',
  String estado = 'ATIVA',
  String? aplicadorId = 'aplicador-1',
  String statusDaD1 = 'PENDENTE',
  bool comAgendamento = true,
  List<Map<String, dynamic>> subpontos = const [],
}) => {
  'id': id,
  'identificador': '#$id',
  'nome': nome,
  'bairro': 'Centro',
  'endereco': 'Rua das Flores',
  'numeroReferencia': 'Ao lado da ponte',
  'descricaoDoTrecho': 'Margem esquerda',
  'larguraMetros': 3.5,
  'profundidadeMetros': 0.8,
  'velocidadeMetrosPorSegundo': 0.4,
  'dosagemMl': 120,
  'distanciaEntreSubpontosMetros': 150,
  'quantidadeDeSubpontos': 3,
  'aplicadorId': ?aplicadorId,
  'estado': estado,
  if (comAgendamento)
    'agendamento': {
      'dataInicio': '2026-10-25',
      'intervaloDias': 7,
      'quantidadeRecorrencias': 2,
      'datas': [
        {'id': '$id-d1', 'data': '2026-10-25', 'status': statusDaD1},
        {'id': '$id-d2', 'data': '2026-11-01', 'status': 'CONCLUIDA'},
      ],
    },
  'subpontos': subpontos,
};

Map<String, dynamic> subpontoDoPull(String id) => {
  'id': id,
  'latitude': -26.9,
  'longitude': -48.9,
  'realizadoEm': '2026-10-20T12:00:00Z',
  'recebidoEm': '2026-10-20T12:01:00Z',
};

/// Corpo de `GET /sync/pull`.
Map<String, dynamic> corpoDoPull(
  List<Map<String, dynamic>> pontos, {
  List<Map<String, dynamic>> produtos = const [
    {'id': 'produto-1', 'nome': 'Larvicida'},
  ],
  String? cursor,
}) => {'pontos': pontos, 'produtos': produtos, 'cursor': ?cursor};

PullResponseDto respostaDoPull(
  List<Map<String, dynamic>> pontos, {
  String? cursor,
}) => PullResponseDto.fromJson(corpoDoPull(pontos, cursor: cursor));
