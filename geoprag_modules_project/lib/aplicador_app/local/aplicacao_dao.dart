import '../../src/entities/aplicacao.dart';
import 'item_da_outbox.dart';

/// Acesso às aplicações registradas no aparelho. Interface para testes com
/// banco em memória.
abstract interface class AplicacaoDao {
  /// Grava a [aplicacao] (cabeçalho e subpontos) **e** os [itens] da outbox na
  /// mesma transação: ou entram os dois, ou nenhum.
  ///
  /// É append-only, como a entidade: cabeçalho e subpontos que já existem não
  /// mudam, então chamar de novo com a aplicação acrescida de um subponto grava
  /// só o novo. Um [ItemDaOutbox] com `id` já existente faz a transação
  /// inteira falhar (e nada é gravado).
  Future<void> gravarComOutbox(Aplicacao aplicacao, List<ItemDaOutbox> itens);

  Future<Aplicacao?> buscarPorId(String id);

  /// Aplicações do [pontoId], da mais antiga para a mais recente.
  Future<List<Aplicacao>> listarPorPonto(String pontoId);
}
