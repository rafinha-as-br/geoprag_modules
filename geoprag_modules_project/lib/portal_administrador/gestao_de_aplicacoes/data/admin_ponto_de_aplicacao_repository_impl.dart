import '../../../src/auditoria/evento_auditoria.dart';
import '../../../src/auditoria/evento_auditoria_repository.dart';
import '../../../src/entities/ponto_de_aplicacao.dart';
import '../../../src/errors/app_exceptions.dart';
import '../core/admin_ponto_de_aplicacao_repository.dart';
import 'mock_pontos_de_aplicacao.dart';

/// Implementação de [AdminPontoDeAplicacaoRepository] sobre a fonte mockada
/// (`mockPontosDeAplicacao`).
///
/// Emite um [EventoAuditoria] (GEOPRAG-113) para cada mutação — este é o
/// único ponto por onde toda mutação de Ponto de Aplicação passa (criação,
/// edição, cancelamento, ativação, atribuição, desativação, inclusive as
/// ações em lote de GEOPRAG-101, que chamam estes mesmos métodos por id),
/// então instrumentar aqui cobre todos os pontos de emissão declarados na
/// issue sem duplicar a chamada em cada Cubit chamador.
///
/// TODO(GEOPRAG-24): substituir por implementação HTTP real assim que o
/// contrato de endpoints deste módulo for validado com o backend.
class AdminPontoDeAplicacaoRepositoryImpl
    implements AdminPontoDeAplicacaoRepository {
  AdminPontoDeAplicacaoRepositoryImpl({
    required EventoAuditoriaRepository eventoAuditoriaRepository,
    required AutorEvento autor,
  }) : _eventoAuditoriaRepository = eventoAuditoriaRepository,
       _autor = autor;

  final EventoAuditoriaRepository _eventoAuditoriaRepository;
  final AutorEvento _autor;
  int _contadorDeEventos = 0;

  Future<void> _registrarEvento(
    String pontoId,
    String tipo,
    Map<String, dynamic> payload,
  ) {
    final agora = DateTime.now();
    return _eventoAuditoriaRepository.registrar(
      EventoAuditoria(
        id: 'evt-$pontoId-${_contadorDeEventos++}',
        pontoAfetadoId: pontoId,
        tipo: tipo,
        autor: _autor,
        dataHoraOcorrencia: agora,
        dataHoraRegistro: agora,
        payload: payload,
      ),
    );
  }

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
    await _registrarEvento(id, 'ciclo_ativado', {
      'dataInicio': agendamento.dataInicio.toIso8601String(),
      'intervaloDias': agendamento.intervaloDias,
      'quantidadeRecorrencias': agendamento.quantidadeRecorrencias,
    });
  }

  @override
  Future<void> desativar(String id) async {
    final antes = await _atualizar(id, (ponto) => ponto.desativar());
    await _registrarEvento(id, 'ponto_desativado', {
      'estadoAnterior': antes.estado.name,
    });
  }

  @override
  Future<void> atribuirAplicador(String id, String aplicadorId) async {
    await _atualizar(id, (ponto) => ponto.atribuirAplicador(aplicadorId));
    await _registrarEvento(id, 'aplicador_atribuido', {
      'aplicadorId': aplicadorId,
    });
  }

  @override
  Future<void> desatribuirAplicador(String id) async {
    final antes = await _atualizar(
      id,
      (ponto) => ponto.desatribuirAplicador(),
    );
    await _registrarEvento(id, 'aplicador_desatribuido', {
      'aplicadorIdAnterior': antes.aplicadorId,
    });
  }

  @override
  Future<void> reativar(String id) async {
    // `antes.estado` é sempre `desativado` (pré-condição do domínio) — o
    // dado que importa no payload é o estado restaurado, guardado em
    // `estadoAnterior` desde o `desativar()` que levou o ponto até aqui.
    final antes = await _atualizar(id, (ponto) => ponto.reativar());
    await _registrarEvento(id, 'ponto_reativado', {
      'estadoRestaurado': antes.estadoAnterior?.name,
    });
  }

  @override
  Future<void> editarNome(String id, String novoNome) async {
    final antes = await _atualizar(id, (ponto) => ponto.editarNome(novoNome));
    await _registrarEvento(id, 'nome_editado', {
      'nomeAnterior': antes.nome,
      'nomeNovo': novoNome,
    });
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
    final antes = await _atualizar(
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
    await _registrarEvento(
      id,
      'cadastro_editado',
      _camposAlterados(
        {
          'nome': antes.nome,
          'bairro': antes.bairro,
          'endereco': antes.endereco,
          'numeroReferencia': antes.numeroReferencia,
          'descricaoDoTrecho': antes.descricaoDoTrecho,
          'larguraMetros': antes.larguraMetros,
          'profundidadeMetros': antes.profundidadeMetros,
          'velocidadeMetrosPorSegundo': antes.velocidadeMetrosPorSegundo,
          'dosagemMl': antes.dosagemMl,
          'distanciaEntreSubpontosMetros': antes.distanciaEntreSubpontosMetros,
          'quantidadeDeSubpontos': antes.quantidadeDeSubpontos,
        },
        {
          'nome': nome,
          'bairro': bairro,
          'endereco': endereco,
          'numeroReferencia': numeroReferencia,
          'descricaoDoTrecho': descricaoDoTrecho,
          'larguraMetros': larguraMetros,
          'profundidadeMetros': profundidadeMetros,
          'velocidadeMetrosPorSegundo': velocidadeMetrosPorSegundo,
          'dosagemMl': dosagemMl,
          'distanciaEntreSubpontosMetros': distanciaEntreSubpontosMetros,
          'quantidadeDeSubpontos': quantidadeDeSubpontos,
        },
      ),
    );
  }

  /// Só os campos cujo valor mudou de [antes] para [depois] — o payload do
  /// evento de auditoria é o delta, não o cadastro inteiro reenviado.
  Map<String, dynamic> _camposAlterados(
    Map<String, dynamic> antes,
    Map<String, dynamic> depois,
  ) {
    final alterados = <String, dynamic>{};
    for (final campo in depois.keys) {
      if (antes[campo] != depois[campo]) {
        alterados[campo] = {'de': antes[campo], 'para': depois[campo]};
      }
    }
    return alterados;
  }

  @override
  Future<void> cancelarAplicacaoQuimica(String id) async {
    await _atualizar(id, (ponto) => ponto.cancelarAplicacaoQuimica());
    await _registrarEvento(id, 'aplicacao_cancelada', const {});
  }

  Future<PontoDeAplicacao> _atualizar(
    String id,
    PontoDeAplicacao Function(PontoDeAplicacao ponto) transicao,
  ) async {
    final index = mockPontosDeAplicacao.indexWhere((ponto) => ponto.id == id);
    if (index == -1) {
      throw EntidadeNaoEncontradaException(
        'Ponto de aplicação "$id" não encontrado.',
      );
    }
    final antes = mockPontosDeAplicacao[index];
    mockPontosDeAplicacao[index] = transicao(antes);
    return antes;
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
    await _registrarEvento(ponto.id, 'ponto_criado', {
      'nome': nome,
      'bairro': bairro,
      'aplicadorId': aplicadorId,
      'estadoInicial': ponto.estado.name,
    });
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
