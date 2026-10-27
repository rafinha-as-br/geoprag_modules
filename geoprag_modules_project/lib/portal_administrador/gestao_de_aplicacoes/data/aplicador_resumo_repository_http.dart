import '../../../src/api/api_client.dart';
import '../../../src/api/sync/sync_json.dart';
import '../../../src/entities/usuario.dart';
import '../core/aplicador_resumo.dart';
import '../core/aplicador_resumo_repository.dart';

/// [AplicadorResumoRepository] sobre `GET /aplicadores`.
class AplicadorResumoRepositoryHttp implements AplicadorResumoRepository {
  AplicadorResumoRepositoryHttp(this._api);

  final ApiClient _api;

  @override
  Future<List<AplicadorResumo>> listar() async {
    final corpo = await _api.get('/aplicadores');
    return [for (final item in objetosDoCorpo(corpo)) _doJson(item)];
  }

  static AplicadorResumo _doJson(Map<String, dynamic> json) => AplicadorResumo(
    id: textoObrigatorio(json, 'id'),
    nome: textoObrigatorio(json, 'nome'),
    status: _status(textoObrigatorio(json, 'status')),
  );

  static UsuarioStatus _status(String valor) => switch (valor) {
    'ATIVO' => UsuarioStatus.ativo,
    'DESATIVADO' => UsuarioStatus.desativado,
    _ => throw FormatException('Status do aplicador desconhecido: "$valor".'),
  };
}
