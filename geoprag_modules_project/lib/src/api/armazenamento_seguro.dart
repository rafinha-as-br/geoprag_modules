import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Armazenamento chave-valor cifrado do aparelho (Keystore no Android,
/// WebCrypto no navegador). É uma interface para que a [SessaoSegura] seja
/// testável sem plugin nativo.
abstract interface class ArmazenamentoSeguro {
  Future<String?> ler(String chave);

  Future<void> gravar(String chave, String valor);

  Future<void> apagar(String chave);
}

/// [ArmazenamentoSeguro] sobre o `flutter_secure_storage`.
class ArmazenamentoSeguroFlutter implements ArmazenamentoSeguro {
  ArmazenamentoSeguroFlutter([FlutterSecureStorage? armazenamento])
    : _armazenamento = armazenamento ?? const FlutterSecureStorage();

  final FlutterSecureStorage _armazenamento;

  @override
  Future<String?> ler(String chave) => _armazenamento.read(key: chave);

  @override
  Future<void> gravar(String chave, String valor) =>
      _armazenamento.write(key: chave, value: valor);

  @override
  Future<void> apagar(String chave) => _armazenamento.delete(key: chave);
}
