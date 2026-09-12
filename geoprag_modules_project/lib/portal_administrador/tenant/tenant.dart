/// Módulo `tenant` (multi-prefeitura) do `portal_administrador`. Diferente
/// dos demais módulos, é consumido programaticamente (bootstrap, guard de
/// rota) e não só como telas — por isso exporta `core`/`data` além de
/// `presentation`.
library;

export '../../src/entities/tenant_config.dart';

export 'data/mock_tenant_configs.dart';
export 'data/tenant_repository_impl.dart';

export 'presentation/tenant_cubit.dart';
export 'presentation/tenant_state.dart';
export 'presentation/tenant_loading_screen.dart';
