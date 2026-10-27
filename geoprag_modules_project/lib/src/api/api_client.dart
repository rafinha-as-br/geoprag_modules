import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../errors/app_error_messages.dart';
import '../errors/app_exceptions.dart';
import 'api_config.dart';
import 'api_exceptions.dart';
import 'sessao_de_tokens.dart';

/// Cliente HTTP único dos dois apps (GEOPRAG-185).
///
/// - Aplica a URL base de [ApiConfig] e o `Authorization: Bearer` da
///   [SessaoDeTokens] em toda chamada autenticada.
/// - Num `401` renova o access token **uma única vez** (várias chamadas
///   simultâneas com `401` esperam a mesma renovação) e refaz a chamada. Se o
///   refresh token é recusado, a sessão é limpa e [aoPerderSessao] avisa o app;
///   se a renovação falha por rede, a sessão é **mantida** (o app segue
///   offline sem perder registros).
/// - Traduz qualquer falha numa exceção com `mensagemAmigavel` (ver
///   `api_exceptions.dart`), nunca deixando vazar `DioException`, URL, token
///   ou o texto de um erro `5xx`.
/// - Até o servidor responder pela primeira vez usa o timeout longo de
///   [ApiConfig.timeoutPrimeiraChamada] (cold start); depois, o padrão.
///
/// Os métodos devolvem o corpo já decodificado (`Map`, `List` ou `null`).
class ApiClient {
  ApiClient({
    required this.config,
    required SessaoDeTokens sessao,
    Dio? dio,
    this.aoPerderSessao,
  }) : _sessao = sessao,
       _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = config.baseUrlDaApi
      ..headers['Accept'] = 'application/json'
      // Quem decide o que é erro é a tradução abaixo, não o status padrão.
      ..validateStatus = (status) =>
          status != null && status >= 200 && status < 300;
  }

  final ApiConfig config;
  final SessaoDeTokens _sessao;
  final Dio _dio;

  /// Chamado quando a sessão não pode mais ser recuperada sem novo login
  /// (refresh token ausente ou recusado). Os tokens já foram apagados.
  final void Function()? aoPerderSessao;

  Future<void>? _renovacaoEmAndamento;
  bool _servidorJaRespondeu = false;

  Future<Object?> get(
    String caminho, {
    Map<String, dynamic>? query,
    bool autenticado = true,
  }) => _enviar('GET', caminho, query: query, autenticado: autenticado);

  Future<Object?> post(
    String caminho, {
    Object? corpo,
    Map<String, dynamic>? query,
    bool autenticado = true,
  }) => _enviar(
    'POST',
    caminho,
    corpo: corpo,
    query: query,
    autenticado: autenticado,
  );

  Future<Object?> put(
    String caminho, {
    Object? corpo,
    Map<String, dynamic>? query,
    bool autenticado = true,
  }) => _enviar(
    'PUT',
    caminho,
    corpo: corpo,
    query: query,
    autenticado: autenticado,
  );

  Future<Object?> patch(
    String caminho, {
    Object? corpo,
    Map<String, dynamic>? query,
    bool autenticado = true,
  }) => _enviar(
    'PATCH',
    caminho,
    corpo: corpo,
    query: query,
    autenticado: autenticado,
  );

  Future<Object?> delete(
    String caminho, {
    Map<String, dynamic>? query,
    bool autenticado = true,
  }) => _enviar('DELETE', caminho, query: query, autenticado: autenticado);

  Future<Object?> _enviar(
    String metodo,
    String caminho, {
    Object? corpo,
    Map<String, dynamic>? query,
    required bool autenticado,
  }) async {
    try {
      final resposta = await _requisitar(
        metodo,
        caminho,
        corpo: corpo,
        query: query,
        autenticado: autenticado,
        podeRenovar: autenticado,
      );
      return _decodificar(resposta.data);
    } on DioException catch (e) {
      throw _traduzir(e);
    }
  }

  Future<Response<String>> _requisitar(
    String metodo,
    String caminho, {
    Object? corpo,
    Map<String, dynamic>? query,
    required bool autenticado,
    required bool podeRenovar,
  }) async {
    final token = autenticado ? await _sessao.accessToken() : null;
    final timeout = _servidorJaRespondeu
        ? config.timeoutPadrao
        : config.timeoutPrimeiraChamada;
    try {
      final resposta = await _dio.request<String>(
        caminho,
        data: corpo,
        queryParameters: query,
        options: Options(
          method: metodo,
          responseType: ResponseType.plain,
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
          connectTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );
      _servidorJaRespondeu = true;
      return resposta;
    } on DioException catch (e) {
      if (e.response != null) _servidorJaRespondeu = true;
      if (podeRenovar && e.response?.statusCode == 401) {
        final renovou = await _renovar(tokenRecusado: token);
        if (renovou) {
          return _requisitar(
            metodo,
            caminho,
            corpo: corpo,
            query: query,
            autenticado: autenticado,
            podeRenovar: false,
          );
        }
      }
      rethrow;
    }
  }

  /// Renova o access token. Devolve `true` se há um token novo para refazer a
  /// chamada e `false` se a sessão acabou (nesse caso o `401` original segue
  /// para o chamador). Falhas de rede/servidor na renovação propagam sem
  /// apagar a sessão.
  Future<bool> _renovar({required String? tokenRecusado}) async {
    final emAndamento = _renovacaoEmAndamento;
    if (emAndamento != null) {
      await emAndamento;
      return (await _sessao.accessToken()) != null;
    }
    // Outra chamada pode ter renovado entre o envio desta e o seu 401.
    final atual = await _sessao.accessToken();
    if (atual != null && atual != tokenRecusado) return true;

    final renovacao = _executarRenovacao();
    _renovacaoEmAndamento = renovacao;
    try {
      await renovacao;
    } finally {
      _renovacaoEmAndamento = null;
    }
    return (await _sessao.accessToken()) != null;
  }

  Future<void> _executarRenovacao() async {
    final refresh = await _sessao.refreshToken();
    if (refresh == null || refresh.isEmpty) {
      await _perderSessao();
      return;
    }
    try {
      final resposta = await _dio.post<String>(
        '/auth/refresh',
        data: {'refreshToken': refresh},
        options: Options(
          responseType: ResponseType.plain,
          connectTimeout: config.timeoutPadrao,
          receiveTimeout: config.timeoutPadrao,
        ),
      );
      final corpo = _decodificar(resposta.data);
      final novoAccess = corpo is Map ? corpo['accessToken'] : null;
      final novoRefresh = corpo is Map ? corpo['refreshToken'] : null;
      if (novoAccess is! String || novoAccess.isEmpty) {
        throw const ErroDoServidorException(AppErrorMessages.erroDoServidor);
      }
      await _sessao.salvar(
        accessToken: novoAccess,
        refreshToken: novoRefresh is String && novoRefresh.isNotEmpty
            ? novoRefresh
            : null,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Recusa explícita: o refresh token não vale mais.
      if (status == 400 || status == 401 || status == 403) {
        await _perderSessao();
        return;
      }
      rethrow;
    }
  }

  Future<void> _perderSessao() async {
    await _sessao.limpar();
    aoPerderSessao?.call();
  }

  static Object? _decodificar(Object? dados) {
    if (dados is String) {
      if (dados.trim().isEmpty) return null;
      try {
        return jsonDecode(dados);
      } on FormatException {
        return dados;
      }
    }
    return dados;
  }

  static Exception _traduzir(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const FalhaDeConexaoException(
          AppErrorMessages.tempoEsgotado,
          tempoEsgotado: true,
        );
      case DioExceptionType.badResponse:
        return _traduzirResposta(e.response!);
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return const FalhaDeConexaoException(AppErrorMessages.semConexao);
    }
  }

  static Exception _traduzirResposta(Response<dynamic> resposta) {
    final status = resposta.statusCode ?? 0;
    final problema = _decodificar(resposta.data);
    final mapa = problema is Map ? problema : const <Object?, Object?>{};
    final codigo = mapa['code'] is String ? mapa['code'] as String : null;
    final detalhe =
        mapa['detail'] is String && (mapa['detail'] as String).trim().isNotEmpty
        ? (mapa['detail'] as String).trim()
        : null;

    if (status >= 500) {
      return ErroDoServidorException(
        AppErrorMessages.erroDoServidor,
        status: status,
      );
    }
    switch (status) {
      case 401:
        return NaoAutenticadoException(
          detalhe ?? AppErrorMessages.sessaoExpirada,
          codigo: codigo,
        );
      case 403:
        return AcessoNegadoException(
          detalhe ?? AppErrorMessages.acessoNegado,
          codigo: codigo,
        );
      case 404:
        return EntidadeNaoEncontradaException(
          detalhe ?? AppErrorMessages.naoEncontrado,
        );
      case 409:
        return OperacaoNaoPermitidaException(
          detalhe ?? AppErrorMessages.operacaoNaoPermitida,
        );
      default:
        return RequisicaoInvalidaException(
          detalhe ?? AppErrorMessages.requisicaoInvalida,
          codigo: codigo,
          status: status,
          erros: _lerErros(mapa['errors']),
        );
    }
  }

  static List<ErroDeCampo> _lerErros(Object? bruto) {
    if (bruto is! List) return const [];
    return [
      for (final item in bruto)
        if (item is Map && item['field'] is String && item['message'] is String)
          ErroDeCampo(
            campo: item['field'] as String,
            mensagem: item['message'] as String,
          ),
    ];
  }
}
