import 'package:geoprag_modules/src/api/auth/usuario_dto.dart';

/// Corpo de `POST /auth/login` como o servidor o devolve.
Map<String, dynamic> respostaDeLogin({
  PerfilDto perfil = PerfilDto.aplicador,
  String id = 'u-0001',
  String tenantId = 'gaspar-sc',
  String? refreshToken = 'refresh-1',
  int expiresInSeconds = 900,
}) => {
  'accessToken': 'access-1',
  'expiresInSeconds': expiresInSeconds,
  if (refreshToken != null) 'refreshToken': refreshToken,
  'usuario': {
    'id': id,
    'nome': 'Fulano de Tal',
    'perfil': perfil.valorJson,
    'tenantId': tenantId,
    'email': 'fulano@exemplo.com',
    'status': 'ATIVO',
  },
};
