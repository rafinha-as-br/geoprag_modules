import '../../../src/api/armazenamento_seguro.dart';
import '../../../src/services/gerador_de_id.dart';

/// Identificador estável deste aparelho para o servidor (`dispositivoId` do
/// lote de `POST /sync/aplicacoes`): um UUID gerado na primeira vez e guardado
/// no [ArmazenamentoSeguro].
class DispositivoId {
  DispositivoId(this._armazenamento, {GeradorDeId? gerador})
    : _gerador = gerador ?? GeradorDeIdUuid();

  static const String _chave = 'geoprag.dispositivo.id';

  final ArmazenamentoSeguro _armazenamento;
  final GeradorDeId _gerador;
  Future<String>? _valor;

  Future<String> obter() => _valor ??= _lerOuCriar();

  Future<String> _lerOuCriar() async {
    final existente = await _armazenamento.ler(_chave);
    if (existente != null && existente.isNotEmpty) return existente;
    final novo = _gerador.gerar();
    await _armazenamento.gravar(_chave, novo);
    return novo;
  }
}
