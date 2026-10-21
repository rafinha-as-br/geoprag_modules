import 'dart:convert';

import 'armazenamento_seguro.dart';
import 'auth/login_dtos.dart';
import 'auth/usuario_dto.dart';
import 'sessao_de_tokens.dart';

/// Sessão restaurada do armazenamento seguro ao reabrir o app.
class SessaoSalva {
  const SessaoSalva({
    required this.usuario,
    required this.temRefreshToken,
    this.accessTokenExpiraEm,
  });

  /// Usuário devolvido pelo login; `id` e `tenantId` vêm do servidor.
  final UsuarioDto usuario;

  /// Só o aplicador recebe refresh token; é ele que mantém a sessão viva por
  /// 30 dias, com o access token já expirado.
  final bool temRefreshToken;

  /// Instante em que o access token do login expira (`null` se desconhecido).
  /// Importa ao portal, que não tem refresh token.
  final DateTime? accessTokenExpiraEm;

  bool accessTokenExpirado(DateTime agora, {Duration margem = Duration.zero}) =>
      accessTokenExpiraEm != null &&
      !agora.add(margem).isBefore(accessTokenExpiraEm!);
}

/// [SessaoDeTokens] persistente (GEOPRAG-187): guarda os tokens e o usuário do
/// login no [ArmazenamentoSeguro], de modo que fechar e reabrir o app mantém a
/// sessão. Tokens nunca vão para `SharedPreferences`, log ou texto de erro.
class SessaoSegura implements SessaoDeTokens {
  SessaoSegura({ArmazenamentoSeguro? armazenamento})
    : _armazenamento = armazenamento ?? ArmazenamentoSeguroFlutter();

  static const String _chaveAccess = 'geoprag.sessao.access_token';
  static const String _chaveRefresh = 'geoprag.sessao.refresh_token';
  static const String _chaveExpiraEm = 'geoprag.sessao.access_expira_em';
  static const String _chaveUsuario = 'geoprag.sessao.usuario';

  final ArmazenamentoSeguro _armazenamento;

  @override
  Future<String?> accessToken() => _armazenamento.ler(_chaveAccess);

  @override
  Future<String?> refreshToken() => _armazenamento.ler(_chaveRefresh);

  @override
  Future<void> salvar({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _armazenamento.gravar(_chaveAccess, accessToken);
    if (refreshToken != null) {
      await _armazenamento.gravar(_chaveRefresh, refreshToken);
    }
  }

  @override
  Future<void> limpar() async {
    await _armazenamento.apagar(_chaveAccess);
    await _armazenamento.apagar(_chaveRefresh);
    await _armazenamento.apagar(_chaveExpiraEm);
    await _armazenamento.apagar(_chaveUsuario);
  }

  /// Guarda a sessão de um login bem-sucedido: tokens, validade do access
  /// token e usuário. Substitui qualquer sessão anterior.
  Future<void> iniciar(
    LoginResponseDto resposta, {
    required DateTime agora,
  }) async {
    await limpar();
    await salvar(
      accessToken: resposta.accessToken,
      refreshToken: resposta.refreshToken,
    );
    await _armazenamento.gravar(
      _chaveExpiraEm,
      agora.add(Duration(seconds: resposta.expiresInSeconds)).toIso8601String(),
    );
    await _armazenamento.gravar(
      _chaveUsuario,
      jsonEncode(resposta.usuario.toJson()),
    );
  }

  /// Lê a sessão guardada. Devolve `null` — e apaga o que sobrou — se ela está
  /// incompleta ou ilegível.
  Future<SessaoSalva?> restaurar() async {
    final bruto = await _armazenamento.ler(_chaveUsuario);
    final access = await accessToken();
    if (bruto == null || access == null || access.isEmpty) {
      if (bruto != null || access != null) await limpar();
      return null;
    }
    try {
      final json = jsonDecode(bruto);
      if (json is! Map<String, dynamic>) throw const FormatException();
      final usuario = UsuarioDto.fromJson(json);
      final refresh = await refreshToken();
      final expiraEm = await _armazenamento.ler(_chaveExpiraEm);
      return SessaoSalva(
        usuario: usuario,
        temRefreshToken: refresh != null && refresh.isNotEmpty,
        accessTokenExpiraEm: expiraEm == null
            ? null
            : DateTime.tryParse(expiraEm),
      );
    } on FormatException {
      await limpar();
      return null;
    }
  }
}
