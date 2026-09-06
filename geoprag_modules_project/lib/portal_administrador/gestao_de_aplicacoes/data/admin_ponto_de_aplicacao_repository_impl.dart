import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/errors/app_exceptions.dart';
import '../core/admin_ponto_de_aplicacao_repository.dart';
import 'mock_pontos_de_aplicacao.dart';

/// Implementação de [AdminPontoDeAplicacaoRepository] sobre a fonte mockada
/// (`mockPontosDeAplicacao`).
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class AdminPontoDeAplicacaoRepositoryImpl
    implements AdminPontoDeAplicacaoRepository {
  @override
  Future<List<PontoDeAplicacao>> listar() async =>
      _comTransicoesAutomaticas(mockPontosDeAplicacao);

  @override
  Future<List<PontoDeAplicacao>> listarPorBairro(String bairro) async {
    return _comTransicoesAutomaticas(
      mockPontosDeAplicacao.where((ponto) => ponto.bairro == bairro).toList(),
    );
  }

  @override
  Future<PontoDeAplicacao> buscarPorId(String id) async {
    final ponto = mockPontosDeAplicacao.firstWhere(
      (ponto) => ponto.id == id,
      orElse: () => throw EntidadeNaoEncontradaException(
        'Ponto de aplicação "$id" não encontrado.',
      ),
    );
    return _aplicarTransicaoAutomatica(ponto);
  }

  /// Transição automática para [EstadoPontoDeAplicacao.inativa] ao cumprir a
  /// última recorrência do agendamento (GEOPRAG-110) — decisão registrada:
  /// derivada na leitura (não há API/job em background nesta versão),
  /// aplicada e persistida aqui, na camada de dados, para as chamadas
  /// seguintes (ex.: tentar `ativar` de novo) verem o estado já atualizado
  /// em vez de um `ativa` que a UI já não mostra mais como tal.
  List<PontoDeAplicacao> _comTransicoesAutomaticas(
    List<PontoDeAplicacao> pontos,
  ) => [for (final ponto in pontos) _aplicarTransicaoAutomatica(ponto)];

  PontoDeAplicacao _aplicarTransicaoAutomatica(PontoDeAplicacao ponto) {
    if (ponto.estado != EstadoPontoDeAplicacao.ativa || !ponto.cicloConcluido) {
      return ponto;
    }
    final atualizado = ponto.copyWith(estado: EstadoPontoDeAplicacao.inativa);
    final index = mockPontosDeAplicacao.indexWhere((p) => p.id == ponto.id);
    if (index != -1) mockPontosDeAplicacao[index] = atualizado;
    return atualizado;
  }

  @override
  Future<void> ativar(String id, Agendamento agendamento) async {
    await _atualizar(id, (ponto) => ponto.ativar(agendamento));
  }

  @override
  Future<void> desativar(String id) async {
    await _atualizar(id, (ponto) => ponto.desativar());
  }

  @override
  Future<void> atribuirAplicador(String id, String aplicadorId) async {
    await _atualizar(id, (ponto) => ponto.atribuirAplicador(aplicadorId));
  }

  @override
  Future<void> desatribuirAplicador(String id) async {
    await _atualizar(id, (ponto) => ponto.desatribuirAplicador());
  }

  @override
  Future<void> reativar(String id) async {
    await _atualizar(id, (ponto) => ponto.reativar());
  }

  @override
  Future<void> editarNome(String id, String novoNome) async {
    await _atualizar(id, (ponto) => ponto.editarNome(novoNome));
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
  }) async {
    await _atualizar(
      id,
      (ponto) => ponto.editarCadastroCompleto(
        nome: nome,
        bairro: bairro,
        endereco: endereco,
        numeroReferencia: numeroReferencia,
        descricaoDoTrecho: descricaoDoTrecho,
        larguraMetros: larguraMetros,
        profundidadeMetros: profundidadeMetros,
        velocidadeMetrosPorSegundo: velocidadeMetrosPorSegundo,
        dosagemMl: dosagemMl,
        distanciaEntreSubpontosMetros: distanciaEntreSubpontosMetros,
        quantidadeDeSubpontos: quantidadeDeSubpontos,
      ),
    );
  }

  @override
  Future<void> cancelarAplicacaoQuimica(String id) async {
    await _atualizar(id, (ponto) => ponto.cancelarAplicacaoQuimica());
  }

  Future<void> _atualizar(
    String id,
    PontoDeAplicacao Function(PontoDeAplicacao ponto) transicao,
  ) async {
    final index = mockPontosDeAplicacao.indexWhere((ponto) => ponto.id == id);
    if (index == -1) {
      throw EntidadeNaoEncontradaException(
        'Ponto de aplicação "$id" não encontrado.',
      );
    }
    mockPontosDeAplicacao[index] = transicao(mockPontosDeAplicacao[index]);
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
  }) async {
    final ponto = PontoDeAplicacao(
      id: 'pa${mockPontosDeAplicacao.length + 1}',
      identificador: _gerarIdentificador(bairro, mockPontosDeAplicacao),
      nome: nome,
      bairro: bairro,
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
      estado: aplicadorId == null
          ? EstadoPontoDeAplicacao.enderecada
          : EstadoPontoDeAplicacao.direcionada,
    );
    mockPontosDeAplicacao.add(ponto);
    return ponto;
  }
}

/// Monta o código curto de um ponto novo (ex.: `#GAS3`): as três primeiras
/// letras do bairro mais a posição do ponto dentro daquele bairro.
///
/// TODO(GEOPRAG-24): a geração definitiva é do backend — aqui ela existe
/// para que o identificador já apareça na UI enquanto a fonte é mockada.
String _gerarIdentificador(String bairro, List<PontoDeAplicacao> existentes) {
  // Acentos são descartados junto com o resto do que não é letra ASCII, o que
  // encurta o prefixo de bairros como "Sé" (#S1) — aceitável enquanto o
  // identificador é gerado aqui e não pelo backend.
  final letras = bairro.replaceAll(RegExp('[^A-Za-z]'), '').toUpperCase();
  final prefixo = letras.length <= 3 ? letras : letras.substring(0, 3);
  final sequencial =
      existentes.where((ponto) => ponto.bairro == bairro).length + 1;
  return '#$prefixo$sequencial';
}
