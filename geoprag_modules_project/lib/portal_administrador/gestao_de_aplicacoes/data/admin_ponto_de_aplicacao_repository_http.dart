import '../../../src/api/api_client.dart';
import '../../../src/api/api_exceptions.dart';
import '../../../src/api/sync/pull_dtos.dart';
import '../../../src/api/sync/sync_json.dart';
import '../../../src/api/sync/sync_mappers.dart';
import '../../../src/entities/atraso_de_aplicacao.dart';
import '../../../src/entities/ponto_de_aplicacao.dart';
import '../core/admin_ponto_de_aplicacao_repository.dart';
import '../core/bairro_repository.dart';

/// [AdminPontoDeAplicacaoRepository] sobre `/pontos` (GEOPRAG-195 e 198).
///
/// Cobre listar, detalhar, criar, editar, atribuir e remover o aplicador,
/// ativar, desativar, reativar, cancelar, editar a tolerância de atraso e
/// remover o alerta de atraso (`POST /pontos/{id}/remocao-de-alerta`,
/// GEOPRAG-216).
///
/// O servidor é a autoridade sobre o estado: as regras de transição (`409`) e
/// de validação (`422`) chegam como exceções com `mensagemAmigavel`, e as
/// telas recarregam o ponto depois de cada ação.
///
/// Particularidades do contrato (GEOPRAG-198):
/// - A API pede `bairroId`; o domínio usa o **nome** do bairro. O id sai de
///   `GET /bairros` pelo nome (sem diferenciar maiúsculas).
/// - `PUT /pontos/{id}` **substitui** o cadastro e, sem `toleranciaAtrasoDias`,
///   volta a tolerância a 4. Por isso [editarCadastroCompleto] sempre envia a
///   tolerância, e [editarNome] e [editarTolerancia] relêem o ponto e reenviam
///   todos os outros campos como estão: o servidor só trava a edição se eles
///   mudarem.
/// - O atraso não vem pronto da API: [idsDePontosEmAtraso] aplica a regra do
///   domínio ([PontoDeAplicacao.estadoDeAtraso]) aos pontos lidos, e a remoção
///   manual do alerta chega em `DataAgendada.alertaRemovidoEm`.
class AdminPontoDeAplicacaoRepositoryHttp
    implements AdminPontoDeAplicacaoRepository {
  /// [agora] é o "hoje" da verificação de atraso; só os testes o trocam.
  AdminPontoDeAplicacaoRepositoryHttp(
    this._api,
    this._bairros, {
    DateTime Function() agora = DateTime.now,
  }) : _agora = agora;

  final ApiClient _api;
  final BairroRepository _bairros;
  final DateTime Function() _agora;

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
  Future<void> desativar(String id) async {
    await _api.post('${_caminho(id)}/desativacao');
  }

  @override
  Future<void> reativar(String id) async {
    await _api.post('${_caminho(id)}/reativacao');
  }

  @override
  Future<void> cancelarAplicacaoQuimica(String id) async {
    await _api.post('${_caminho(id)}/cancelamento');
  }

  /// Relê o ponto e reenvia o cadastro como está, só com o nome novo. O
  /// servidor aceita mesmo com o cadastro travado porque nada além do nome
  /// muda.
  @override
  Future<void> editarNome(String id, String novoNome) async {
    final atual = _objeto(await _api.get(_caminho(id)));
    await _api.put(
      _caminho(id),
      corpo: {...await _corpoDoCadastroAtual(atual), 'nome': novoNome.trim()},
    );
  }

  /// Corpo de `PUT /pontos/{id}` com o cadastro de [atual] como está.
  Future<Map<String, dynamic>> _corpoDoCadastroAtual(
    Map<String, dynamic> atual,
  ) async => {
    'nome': atual['nome'],
    'bairroId':
        textoOpcional(atual, 'bairroId') ??
        await _idDoBairro(textoObrigatorio(atual, 'bairro')),
    'endereco': atual['endereco'],
    'numeroReferencia': ?atual['numeroReferencia'],
    'descricaoDoTrecho': ?atual['descricaoDoTrecho'],
    'larguraMetros': ?atual['larguraMetros'],
    'profundidadeMetros': ?atual['profundidadeMetros'],
    'velocidadeMetrosPorSegundo': ?atual['velocidadeMetrosPorSegundo'],
    'dosagemMl': atual['dosagemMl'],
    'distanciaEntreSubpontosMetros': atual['distanciaEntreSubpontosMetros'],
    'quantidadeDeSubpontos': atual['quantidadeDeSubpontos'],
    'toleranciaAtrasoDias': ?atual['toleranciaAtrasoDias'],
  };

  /// Relê o ponto e reenvia o cadastro como está, só com a tolerância nova. A
  /// regra de valor mínimo é a do domínio ([PontoDeAplicacao.editarTolerancia]).
  @override
  Future<void> editarTolerancia(String id, int novaToleranciaDias) async {
    final atual = _objeto(await _api.get(_caminho(id)));
    _ponto(atual).editarTolerancia(novaToleranciaDias);
    await _api.put(
      _caminho(id),
      corpo: {
        ...await _corpoDoCadastroAtual(atual),
        'toleranciaAtrasoDias': novaToleranciaDias,
      },
    );
  }

  @override
  Future<Set<String>> idsDePontosEmAtraso() async {
    final agora = _agora();
    return {
      for (final ponto in await _listar())
        if (ponto.estadoDeAtraso(dataDeReferencia: agora) ==
            EstadoDeAtraso.emAtraso)
          ponto.id,
    };
  }

  /// O servidor decide se o alerta existe: fora de atraso (ou já removido) ele
  /// responde `409`, e a mensagem chega como exceção da API.
  @override
  Future<void> removerAlertaDeAtraso(String id) async {
    await _api.post('${_caminho(id)}/remocao-de-alerta');
  }

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
    required int toleranciaDias,
  }) async {
    await _api.put(
      _caminho(id),
      corpo: _corpoDoCadastro(
        nome: nome,
        bairroId: await _idDoBairro(bairro),
        endereco: endereco,
        numeroReferencia: numeroReferencia,
        descricaoDoTrecho: descricaoDoTrecho,
        larguraMetros: larguraMetros,
        profundidadeMetros: profundidadeMetros,
        velocidadeMetrosPorSegundo: velocidadeMetrosPorSegundo,
        dosagemMl: dosagemMl,
        distanciaEntreSubpontosMetros: distanciaEntreSubpontosMetros,
        quantidadeDeSubpontos: quantidadeDeSubpontos,
        toleranciaAtrasoDias: toleranciaDias,
      ),
    );
  }

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
    int toleranciaDias = toleranciaPadraoDeAtrasoEmDias,
  }) async => _ponto(
    await _api.post(
      '/pontos',
      corpo: _corpoDoCadastro(
        nome: nome,
        bairroId: await _idDoBairro(bairro),
        endereco: endereco,
        numeroReferencia: numeroReferencia,
        descricaoDoTrecho: descricaoDoTrecho,
        larguraMetros: larguraMetros,
        profundidadeMetros: profundidadeMetros,
        velocidadeMetrosPorSegundo: velocidadeMetrosPorSegundo,
        dosagemMl: dosagemMl,
        distanciaEntreSubpontosMetros: distanciaEntreSubpontosMetros,
        quantidadeDeSubpontos: quantidadeDeSubpontos,
        aplicadorId: aplicadorId,
        toleranciaAtrasoDias: toleranciaDias,
      ),
    ),
  );

  static String _caminho(String id) => '/pontos/${Uri.encodeComponent(id)}';

  /// Corpo de `POST /pontos` e `PUT /pontos/{id}`. Campos opcionais vazios (ou
  /// medidas sem valor, `0`) vão omitidos: o servidor os guarda como "sem
  /// valor". As medidas seguem as 2 casas decimais que a API aceita.
  static Map<String, dynamic> _corpoDoCadastro({
    required String nome,
    required String bairroId,
    required String endereco,
    required String numeroReferencia,
    required String descricaoDoTrecho,
    required double larguraMetros,
    required double profundidadeMetros,
    required double velocidadeMetrosPorSegundo,
    required double dosagemMl,
    required double distanciaEntreSubpontosMetros,
    required int quantidadeDeSubpontos,
    Object? toleranciaAtrasoDias,
    String? aplicadorId,
  }) => {
    'nome': nome.trim(),
    'bairroId': bairroId,
    'endereco': endereco.trim(),
    'numeroReferencia': ?_textoOuNulo(numeroReferencia),
    'descricaoDoTrecho': ?_textoOuNulo(descricaoDoTrecho),
    'larguraMetros': ?_medidaOuNula(larguraMetros),
    'profundidadeMetros': ?_medidaOuNula(profundidadeMetros),
    'velocidadeMetrosPorSegundo': ?_medidaOuNula(velocidadeMetrosPorSegundo),
    'dosagemMl': _duasCasas(dosagemMl),
    'distanciaEntreSubpontosMetros': _duasCasas(distanciaEntreSubpontosMetros),
    'quantidadeDeSubpontos': quantidadeDeSubpontos,
    'toleranciaAtrasoDias': ?toleranciaAtrasoDias,
    'aplicadorId': ?aplicadorId,
  };

  static String? _textoOuNulo(String texto) {
    final limpo = texto.trim();
    return limpo.isEmpty ? null : limpo;
  }

  static double? _medidaOuNula(double valor) {
    final arredondado = _duasCasas(valor);
    return arredondado > 0 ? arredondado : null;
  }

  static double _duasCasas(double valor) =>
      double.parse(valor.toStringAsFixed(2));

  /// O `id` do bairro de nome [nome]. Lança [RequisicaoInvalidaException] com
  /// uma mensagem clara se não houver bairro com esse nome.
  Future<String> _idDoBairro(String nome) async {
    final alvo = nome.trim().toLowerCase();
    for (final bairro in await _bairros.listar()) {
      if (bairro.nome.trim().toLowerCase() == alvo) return bairro.id;
    }
    throw RequisicaoInvalidaException(
      'O bairro "${nome.trim()}" não está cadastrado. Informe um bairro '
      'existente.',
    );
  }

  static Map<String, dynamic> _objeto(Object? corpo) =>
      corpo is Map<String, dynamic>
      ? corpo
      : throw const FormatException('A API devolveu algo que não é um ponto.');

  Future<List<PontoDeAplicacao>> _listar({Map<String, dynamic>? query}) async {
    final corpo = await _api.get('/pontos', query: query);
    return [for (final item in objetosDoCorpo(corpo)) _ponto(item)];
  }

  /// Mesmo modelo `Ponto` do contrato v0 que o pull entrega ao aplicador; o
  /// que a API acrescenta (marca de conflito dos subpontos) é lido pela
  /// GEOPRAG-207.
  static PontoDeAplicacao _ponto(Object? corpo) =>
      SyncMappers.paraPonto(PontoDoAplicadorDto.fromJson(_objeto(corpo)));
}
