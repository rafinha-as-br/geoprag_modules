import '../../../src/api/armazenamento_seguro.dart';

/// Horário da última sincronização bem-sucedida, guardado no
/// [ArmazenamentoSeguro] para sobreviver ao fechamento do app (GEOPRAG-204).
class UltimaSincronizacao {
  UltimaSincronizacao(this._armazenamento);

  static const String _chave = 'geoprag.sincronizacao.ultima_bem_sucedida';

  final ArmazenamentoSeguro _armazenamento;

  /// `null` se nunca houve uma, ou se o valor guardado é ilegível.
  Future<DateTime?> ler() async {
    final texto = await _armazenamento.ler(_chave);
    if (texto == null) return null;
    return DateTime.tryParse(texto)?.toLocal();
  }

  Future<void> gravar(DateTime instante) =>
      _armazenamento.gravar(_chave, instante.toUtc().toIso8601String());
}
