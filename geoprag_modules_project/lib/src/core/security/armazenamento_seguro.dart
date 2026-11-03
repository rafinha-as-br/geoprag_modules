import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Armazenamento chave-valor cifrado do aparelho (Keystore no Android). É uma
/// interface para que a [SessaoSegura] seja testável sem plugin nativo.
///
/// No navegador o `flutter_secure_storage` guarda no `localStorage` do mesmo
/// origin (cifrado por WebCrypto, mas com a chave ao alcance da página): isso
/// não protege contra script injetado (XSS), então o access token do portal só
/// é tão seguro quanto o origin dele.
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
