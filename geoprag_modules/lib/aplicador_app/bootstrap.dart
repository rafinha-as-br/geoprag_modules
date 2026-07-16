import 'auth/core/auth_repository.dart';
import 'auth/data/auth_repository_impl.dart';
import 'auth/presentation/esqueci_senha_cubit.dart';
import 'auth/presentation/login_cubit.dart';
import 'auth/presentation/recriar_senha_cubit.dart';
import 'auth/presentation/verificar_codigo_cubit.dart';
import 'tenant/core/tenant_config.dart';
import 'tenant/data/mbtiles_downloader.dart';
import 'tenant/data/tenant_repository_impl.dart';
import 'tenant/presentation/tenant_cubit.dart';

/// DI manual do `aplicador_app`: fábricas que resolvem a instância concreta
/// dos repositórios para cada Bloc/Cubit. Cada `GoRoute.builder` (ver
/// `main.dart` do app) chama a fábrica correspondente ao montar o
/// `BlocProvider` da tela — nunca um `MultiBlocProvider` global.
class AplicadorBootstrap {
  const AplicadorBootstrap();

  AuthRepository buildAuthRepository() => AuthRepositoryImpl();
  TenantRepository buildTenantRepository() => TenantRepositoryImpl();

  LoginCubit buildLoginCubit() => LoginCubit(buildAuthRepository());
  EsqueciSenhaCubit buildEsqueciSenhaCubit() =>
      EsqueciSenhaCubit(buildAuthRepository());
  VerificarCodigoCubit buildVerificarCodigoCubit() =>
      VerificarCodigoCubit(buildAuthRepository());
  RecriarSenhaCubit buildRecriarSenhaCubit() =>
      RecriarSenhaCubit(buildAuthRepository());

  TenantCubit buildTenantCubit() =>
      TenantCubit(buildTenantRepository(), MbtilesDownloader());
}
