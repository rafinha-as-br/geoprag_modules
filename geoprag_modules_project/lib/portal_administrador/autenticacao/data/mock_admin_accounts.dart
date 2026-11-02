import '../core/admin_account.dart';

/// Tenant das contas simuladas, coerente com o ambiente do build.
///
/// No piloto de homologação o login precisa devolver o tenant isolado de
/// Gaspar; nos demais ambientes as contas de desenvolvimento continuam no
/// tenant histórico. Em produção a origem desse dado é sempre a API.
const _ambienteDasContasMock = String.fromEnvironment(
  'GEOPRAG_ENV',
  defaultValue: 'desenvolvimento',
);
const _tenantDasContasMock =
    _ambienteDasContasMock == 'homologacao' ||
        _ambienteDasContasMock == 'homologação' ||
        _ambienteDasContasMock == 'hml'
    ? 'gaspar-sc-hml'
    : 'gaspar-sc';

/// Contas usadas para simular, na tela "Esqueci minha senha" do portal web,
/// a distinção de papel que em produção viria do backend: Administrador
/// principal (verificação por e-mail + CPF) ou Sub-Administrador (requer
/// autorização do Administrador principal).
final List<AdminAccount> mockAdminAccounts = [
  AdminAccount(
    id: 'adm-1',
    tenantId: _tenantDasContasMock,
    email: 'admin@gaspar.sc.gov.br',
    nome: 'Marcos Vieira',
    cpf: '123.456.789-00',
    dataNascimento: DateTime(1980, 5, 12),
    sexo: 'Masculino',
    dataCriacao: DateTime(2026, 1, 10),
    role: AdminRole.administrador,
  ),
  AdminAccount(
    id: 'adm-2',
    tenantId: _tenantDasContasMock,
    email: 'celia.ramos@gaspar.sc.gov.br',
    nome: 'Célia Ramos',
    cpf: '987.654.321-00',
    dataNascimento: DateTime(1990, 3, 20),
    sexo: 'Feminino',
    dataCriacao: DateTime(2026, 2, 3),
    role: AdminRole.subAdministrador,
  ),
];

/// Senha aceita para qualquer conta de [mockAdminAccounts] enquanto o login
/// é simulado — só existe para permitir exercitar sucesso/falha na UI.
const String mockAdminSenha = '123456';
