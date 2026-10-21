import '../../../src/api/api_client.dart';
import '../../../src/api/sync/pull_dtos.dart';
import '../../../src/api/sync/sync_json.dart';
import '../../../src/api/sync/sync_mappers.dart';
import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../core/admin_ponto_de_aplicacao_repository.dart';

/// [AdminPontoDeAplicacaoRepository] sobre `/pontos` (GEOPRAG-195).
///
/// Cobre listar, detalhar, atribuir e remover o aplicador e ativar. As demais
/// ações do contrato (criar, editar, desativar, reativar e cancelar) ainda não
/// foram ligadas à API (GEOPRAG-198) e respondem com
/// [OperacaoNaoPermitidaException] em vez de operar sobre dados de mentira.
///
/// O servidor é a autoridade sobre o estado: as regras de transição (`409`) e
/// de validação (`422`) chegam como exceções com `mensagemAmigavel`, e as
/// telas recarregam o ponto depois de cada ação.
class AdminPontoDeAplicacaoRepositoryHttp
    implements AdminPontoDeAplicacaoRepository {
  AdminPontoDeAplicacaoRepositoryHttp(this._api);

  final ApiClient _api;

  @override
  Future<List<PontoDeAplicacao>> listar() => _listar();

  @override
  Future<List<PontoDeAplicacao>> listarPorBairro(String bairro) =>
      _listar(query: {'bairro': bairro});

  @override
  Future<PontoDeAplicacao> buscarPorId(String id) async =>
      _ponto(await _api.get(_caminho(id)));

  /// Só `dataInicio`, `intervaloDias` e `quantidadeRecorrencias` vão ao
  /// servidor: ele gera as datas (e os `id` delas). As datas que o
  /// [Agendamento] do cliente traz são descartadas.
  @override
  Future<void> ativar(String id, Agendamento agendamento) async {
    await _api.post(
      '${_caminho(id)}/ativacao',
      corpo: {
        'dataInicio': formatarDataDeCalendario(agendamento.dataInicio),
        'intervaloDias': agendamento.intervaloDias,
        'quantidadeRecorrencias': agendamento.quantidadeRecorrencias,
      },
    );
  }

  @override
  Future<void> atribuirAplicador(String id, String aplicadorId) async {
    await _api.post(
      '${_caminho(id)}/aplicador',
      corpo: {'aplicadorId': aplicadorId},
    );
  }

  @override
  Future<void> desatribuirAplicador(String id) async {
    await _api.delete('${_caminho(id)}/aplicador');
  }

  @override
  Future<void> desativar(String id) => _aindaNaoLigada();

  @override
  Future<void> reativar(String id) => _aindaNaoLigada();

  @override
  Future<void> editarNome(String id, String novoNome) => _aindaNaoLigada();

  @override
  Future<void> editarCadastroCompleto(
    String id, {
    required String nome,
    required String bairro,
    required String endereco,
    required String numeroReferencia,
    required String descricaoDoTrecho,
    required double larguraMetros,
    required double profundidadeMetros,
    required double velocidadeMetrosPorSegundo,
    required double dosagemMl,
    required double distanciaEntreSubpontosMetros,
    required int quantidadeDeSubpontos,
  }) => _aindaNaoLigada();

  @override
  Future<void> cancelarAplicacaoQuimica(String id) => _aindaNaoLigada();

  @override
  Future<PontoDeAplicacao> criar({
    required String nome,
    required String bairro,
    required String endereco,
    required String numeroReferencia,
    required String descricaoDoTrecho,
    required double larguraMetros,
    required double profundidadeMetros,
    required double velocidadeMetrosPorSegundo,
    required double dosagemMl,
    required double distanciaEntreSubpontosMetros,
    required int quantidadeDeSubpontos,
    String? aplicadorId,
  }) => _aindaNaoLigada();

  static String _caminho(String id) => '/pontos/${Uri.encodeComponent(id)}';

  Future<List<PontoDeAplicacao>> _listar({Map<String, dynamic>? query}) async {
    final corpo = await _api.get('/pontos', query: query);
    return [for (final item in objetosDoCorpo(corpo)) _ponto(item)];
  }

  /// Mesmo modelo `Ponto` do contrato v0 que o pull entrega ao aplicador; o
  /// que a API acrescenta (marca de conflito dos subpontos) é lido pela
  /// GEOPRAG-207.
  static PontoDeAplicacao _ponto(Object? corpo) => SyncMappers.paraPonto(
    PontoDoAplicadorDto.fromJson(
      corpo is Map<String, dynamic>
          ? corpo
          : throw const FormatException(
              'A API devolveu algo que não é um ponto.',
            ),
    ),
  );

  Future<T> _aindaNaoLigada<T>() async =>
      throw const OperacaoNaoPermitidaException(
        AppErrorMessages.acaoIndisponivelNestaVersao,
      );
}
