import '../../src/entities/ponto_de_aplicacao.dart';

/// Acesso aos pontos atribuídos ao aplicador, guardados no aparelho. Interface
/// para testes com banco em memória.
abstract interface class PontoDao {
  /// Insere ou atualiza o [ponto] e suas datas agendadas. Os subpontos que o
  /// servidor já registrou são acrescentados, nunca substituídos: um subponto
  /// feito neste aparelho e ainda não sincronizado continua lá.
  Future<void> salvar(PontoDeAplicacao ponto);

  /// [salvar] para vários pontos, numa única transação.
  Future<void> salvarTodos(Iterable<PontoDeAplicacao> pontos);

  Future<PontoDeAplicacao?> buscarPorId(String id);

  /// Pontos guardados, por nome; só os do [aplicadorId] quando informado.
  Future<List<PontoDeAplicacao>> listar({String? aplicadorId});

  /// Tira o ponto do aparelho, com as datas agendadas e os subpontos que vieram
  /// do servidor. Aplicações e subpontos feitos aqui, e a outbox, não são
  /// tocados: a regra de não remover ponto com registro pendente é de quem
  /// sincroniza (ver `OutboxDao.pontoIdsComPendencias`).
  Future<void> remover(String id);
}
