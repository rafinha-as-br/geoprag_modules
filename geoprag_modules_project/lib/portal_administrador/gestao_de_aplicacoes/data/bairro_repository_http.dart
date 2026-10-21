import '../../../src/api/api_client.dart';
import '../../../src/api/sync/sync_json.dart';
import '../core/bairro.dart';
import '../core/bairro_repository.dart';

/// [BairroRepository] sobre `GET /bairros`.
class BairroRepositoryHttp implements BairroRepository {
  BairroRepositoryHttp(this._api);

  final ApiClient _api;

  @override
  Future<List<Bairro>> listar() async {
    final corpo = await _api.get('/bairros');
    return [
      for (final item in objetosDoCorpo(corpo))
        Bairro(
          id: textoObrigatorio(item, 'id'),
          nome: textoObrigatorio(item, 'nome'),
        ),
    ];
  }
}
