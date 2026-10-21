import 'json_helpers.dart';
import 'usuario_dto.dart';

/// Corpo de `POST /auth/login`: CPF ou e-mail e senha.
class LoginRequestDto {
  const LoginRequestDto({required this.identificador, required this.senha});

  /// Rota do login (pública, sem token).
  static const String caminho = '/auth/login';

  final String identificador;
  final String senha;

  Map<String, dynamic> toJson() => {
    'identificador': identificador,
    'senha': senha,
  };

  /// Nunca expõe o identificador nem a senha em logs.
  @override
  String toString() => 'LoginRequestDto(...)';
}

/// Resposta de `POST /auth/login`. [refreshToken] só vem para o aplicador.
class LoginResponseDto {
  const LoginResponseDto({
    required this.accessToken,
    required this.expiresInSeconds,
    required this.usuario,
    this.refreshToken,
  });

  final String accessToken;
  final int expiresInSeconds;
  final String? refreshToken;
  final UsuarioDto usuario;

  /// Lê o corpo decodificado devolvido pelo `ApiClient`; qualquer formato que
  /// não seja um objeto JSON vira [FormatException].
  factory LoginResponseDto.fromCorpo(Object? corpo) {
    if (corpo is Map<String, dynamic>) return LoginResponseDto.fromJson(corpo);
    throw const FormatException('Resposta de login em formato inesperado.');
  }

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      LoginResponseDto(
        accessToken: textoObrigatorio(json, 'accessToken'),
        expiresInSeconds: inteiroObrigatorio(json, 'expiresInSeconds'),
        refreshToken: textoOpcional(json, 'refreshToken'),
        usuario: UsuarioDto.fromJson(objetoObrigatorio(json, 'usuario')),
      );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'expiresInSeconds': expiresInSeconds,
    if (refreshToken != null) 'refreshToken': refreshToken,
    'usuario': usuario.toJson(),
  };

  /// Nunca expõe tokens em logs.
  @override
  String toString() => 'LoginResponseDto(usuario: $usuario)';
}

/// Corpo de `POST /auth/refresh`.
class RefreshRequestDto {
  const RefreshRequestDto({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};

  @override
  String toString() => 'RefreshRequestDto(...)';
}

/// Resposta de `POST /auth/refresh`: novo par de tokens (o refresh é rotativo).
class RefreshResponseDto {
  const RefreshResponseDto({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory RefreshResponseDto.fromJson(Map<String, dynamic> json) =>
      RefreshResponseDto(
        accessToken: textoObrigatorio(json, 'accessToken'),
        refreshToken: textoObrigatorio(json, 'refreshToken'),
      );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };

  @override
  String toString() => 'RefreshResponseDto(...)';
}
