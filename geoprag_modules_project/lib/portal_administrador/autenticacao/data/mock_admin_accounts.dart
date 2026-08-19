import '../core/admin_account.dart';

/// Contas usadas para simular, na tela "Esqueci minha senha" do portal web,
/// a distinção de papel que em produção viria do backend: Administrador
/// principal (verificação por e-mail + CPF) ou Sub-Administrador (requer
/// autorização do Administrador principal).
final List<AdminAccount> mockAdminAccounts = [
  AdminAccount(
    email: 'admin@gaspar.sc.gov.br',
    nome: 'Marcos Vieira',
    role: AdminRole.administrador,
  ),
  AdminAccount(
    email: 'celia.ramos@gaspar.sc.gov.br',
    nome: 'Célia Ramos',
    role: AdminRole.subAdministrador,
  ),
];

/// Senha aceita para qualquer conta de [mockAdminAccounts] enquanto o login
/// é simulado — só existe para permitir exercitar sucesso/falha na UI.
const String mockAdminSenha = '123456';
