import 'package:uuid/uuid.dart';

/// Gera identificadores únicos para os registros criados no aparelho.
///
/// Existe como interface injetável para que o identificador de um registro
/// nasça num único lugar e seja previsível nos testes. Sem um `id` gerado no
/// app não há idempotência no reenvio da sincronização (GEOPRAG-188).
abstract interface class GeradorDeId {
  /// Um identificador novo (UUID v4 na implementação de produção).
  String gerar();
}

/// [GeradorDeId] de produção: UUID v4.
class GeradorDeIdUuid implements GeradorDeId {
  GeradorDeIdUuid();

  final Uuid _uuid = const Uuid();

  @override
  String gerar() => _uuid.v4();

  static final RegExp _formatoUuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  /// Se [valor] está no formato canônico de um UUID v4 (minúsculas).
  static bool ehUuidV4(String valor) => _formatoUuidV4.hasMatch(valor);
}
