import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/application/admin_portal_runtime.dart';
import 'package:geoprag_modules/src/core/environment/build_environment.dart';
import 'package:geoprag_modules/src/features/homologacao/domain/politica_do_portal_admin.dart';

void main() {
  group('GeopragBuildEnvironmentConfig', () {
    test('aceita os valores de build documentados', () {
      expect(
        GeopragBuildEnvironmentConfig.deValor('homologacao').value,
        GeopragBuildEnvironment.homologacao,
      );
      expect(
        GeopragBuildEnvironmentConfig.deValor('production').value,
        GeopragBuildEnvironment.producao,
      );
    });

    test('recusa ambiente desconhecido em vez de assumir produção', () {
      expect(
        () => GeopragBuildEnvironmentConfig.deValor('prefeitura'),
        throwsArgumentError,
      );
    });
  });

  group('AdminPortalRuntime em homologação', () {
    final runtime = AdminPortalRuntime(
      environment: GeopragBuildEnvironmentConfig.deValor('homologacao'),
    );

    test('libera somente as áreas conectadas ao piloto', () {
      expect(runtime.permiteSecao(SecaoDoPortalAdmin.aplicacoes), isTrue);
      expect(runtime.permiteSecao(SecaoDoPortalAdmin.aplicadores), isFalse);
      expect(runtime.permiteSecao(SecaoDoPortalAdmin.estoque), isFalse);
      expect(runtime.permiteSecao(SecaoDoPortalAdmin.visaoGeral), isFalse);
      expect(runtime.permiteSimulacaoDeAplicacao, isTrue);
    });

    test('libera somente rotas de módulos do piloto', () {
      expect(runtime.permiteRotaDeModulo('/aplicacoes/pa-1'), isTrue);
      expect(runtime.permiteRotaDeModulo('/aplicadores'), isFalse);
      expect(runtime.permiteRotaDeModulo('/estoque'), isFalse);
    });

    test('aceita somente o tenant isolado de homologação', () {
      expect(
        () => runtime.validarTenantDoPortal('gaspar-sc'),
        throwsArgumentError,
      );
      expect(
        () => runtime.validarTenantDoPortal('gaspar-sc-hml'),
        returnsNormally,
      );
    });
  });
}
