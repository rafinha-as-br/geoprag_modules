import '../../../src/api/armazenamento_seguro.dart';
import '../../../src/api/sessao_segura.dart';

/// Cursor do pull incremental (GEOPRAG-206): o instante do servidor devolvido
/// pelo último pull que o aparelho reconciliou por inteiro. O próximo pull o
/// envia como `desde` e recebe só o que mudou.
///
/// Fica no [ArmazenamentoSeguro] sob a chave da sessão
/// ([SessaoSegura.chaveDoCursorDoPull]): login e logout o apagam, e o primeiro
/// pull de uma sessão nova é sempre o snapshot completo.
class CursorDoPull {
  CursorDoPull(this._armazenamento);

  final ArmazenamentoSeguro _armazenamento;

  /// `null` se não há cursor ou se o valor guardado é ilegível: nos dois casos
  /// o pull é o snapshot completo.
  Future<DateTime?> ler() async {
    final texto = await _armazenamento.ler(SessaoSegura.chaveDoCursorDoPull);
    return texto == null ? null : DateTime.tryParse(texto);
  }

  Future<void> gravar(DateTime cursor) => _armazenamento.gravar(
    SessaoSegura.chaveDoCursorDoPull,
    cursor.toUtc().toIso8601String(),
  );

  Future<void> apagar() =>
      _armazenamento.apagar(SessaoSegura.chaveDoCursorDoPull);
}
