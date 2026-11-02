import 'package:flutter/foundation.dart';

import '../core/environment/build_environment.dart';
import '../features/homologacao/domain/politica_do_portal_admin.dart';

/// Composição de ambiente e capacidades do Portal Administrador.
class AdminPortalRuntime {
  const AdminPortalRuntime({required GeopragBuildEnvironmentConfig environment})
    : _environment = environment;

  /// Cria a composição a partir dos `dart-defines` do build Flutter.
  factory AdminPortalRuntime.doAmbiente() => AdminPortalRuntime(
    environment: GeopragBuildEnvironmentConfig.doAmbiente(),
  );

  final GeopragBuildEnvironmentConfig _environment;

  static AdminPortalRuntime? _overrideForTesting;

  /// Instância compartilhada pelo Portal no processo atual.
  static AdminPortalRuntime get atual =>
      _overrideForTesting ?? AdminPortalRuntime.doAmbiente();

  GeopragBuildEnvironment get environment => _environment.value;

  PoliticaDoPortalAdmin get politica => PoliticaDoPortalAdmin(_environment);

  bool get isHomologacao => politica.isHomologacao;

  bool get permiteSimulacaoDeAplicacao => politica.permiteSimulacaoDeAplicacao;

  bool permiteSecao(SecaoDoPortalAdmin secao) => politica.permiteSecao(secao);

  bool permiteRotaDeModulo(String location) =>
      politica.permiteRotaDeModulo(location);

  void validarTenantDoPortal(String tenantId) =>
      politica.validarTenantDoPortal(tenantId);

  @visibleForTesting
  static void configurarParaTeste(AdminPortalRuntime runtime) {
    _overrideForTesting = runtime;
  }

  @visibleForTesting
  static void limparConfiguracaoDeTeste() {
    _overrideForTesting = null;
  }
}
