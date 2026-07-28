import 'autenticacao/core/admin_auth_repository.dart';
import 'autenticacao/data/admin_auth_repository_impl.dart';
import 'autenticacao/presentation/admin_esqueci_senha_cubit.dart';
import 'autenticacao/presentation/admin_login_cubit.dart';
import 'autenticacao/presentation/admin_recriar_senha_cubit.dart';
import 'tenant/core/tenant_config.dart';
import 'tenant/data/tenant_repository_impl.dart';
import 'tenant/presentation/tenant_cubit.dart';

/// DI manual do `portal_administrador`: fábricas que resolvem a instância
/// concreta dos repositórios para cada Bloc/Cubit. Cada `GoRoute.builder`
/// (ver `main.dart` do app) chama a fábrica correspondente ao montar o
/// `BlocProvider` da tela — nunca um `MultiBlocProvider` global.
class AdminBootstrap {
  const AdminBootstrap();

  AdminAuthRepository buildAdminAuthRepository() => AdminAuthRepositoryImpl();
  TenantRepository buildTenantRepository() => TenantRepositoryImpl();

  AdminLoginCubit buildAdminLoginCubit() =>
      AdminLoginCubit(buildAdminAuthRepository());
  AdminEsqueciSenhaCubit buildAdminEsqueciSenhaCubit() =>
      AdminEsqueciSenhaCubit(buildAdminAuthRepository());
  AdminRecriarSenhaCubit buildAdminRecriarSenhaCubit() =>
      AdminRecriarSenhaCubit(buildAdminAuthRepository());

  TenantCubit buildTenantCubit() => TenantCubit(buildTenantRepository());
}
