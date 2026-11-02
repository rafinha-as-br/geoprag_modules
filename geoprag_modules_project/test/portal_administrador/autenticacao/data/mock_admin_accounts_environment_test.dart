import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/data/mock_admin_accounts.dart';

const _ambiente = String.fromEnvironment(
  'GEOPRAG_ENV',
  defaultValue: 'desenvolvimento',
);
const _tenantEsperado =
    _ambiente == 'homologacao' ||
        _ambiente == 'homologação' ||
        _ambiente == 'hml'
    ? 'gaspar-sc-hml'
    : 'gaspar-sc';

void main() {
  test('contas simuladas respeitam o tenant do ambiente de compilação', () {
    expect(
      mockAdminAccounts.map((conta) => conta.tenantId),
      everyElement(_tenantEsperado),
    );
  });
}
