import '../core/usuario.dart';

/// Usuários usados para simular o login do Aplicador enquanto o contrato
/// real de endpoints de autenticação não é validado com o backend.
final List<Usuario> mockUsers = [
  const Usuario(
    id: 'u1',
    nome: 'João Silva',
    cpf: '000.000.000-00',
    tenantId: 'gaspar-sc',
  ),
];

/// Senha aceita para qualquer usuário de [mockUsers] enquanto o login é
/// simulado — só existe para permitir exercitar sucesso/falha na UI.
const String mockUserSenha = '123456';
