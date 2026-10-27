import 'package:geoprag_modules/src/api/armazenamento_seguro.dart';

/// [ArmazenamentoSeguro] em memória para os testes (sem plugin nativo).
class ArmazenamentoEmMemoria implements ArmazenamentoSeguro {
  final Map<String, String> dados = {};

  @override
  Future<String?> ler(String chave) async => dados[chave];

  @override
  Future<void> gravar(String chave, String valor) async => dados[chave] = valor;

  @override
  Future<void> apagar(String chave) async => dados.remove(chave);
}
