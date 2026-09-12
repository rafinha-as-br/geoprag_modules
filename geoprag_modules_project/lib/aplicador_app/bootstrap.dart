import 'auth/core/auth_repository.dart';
import 'auth/data/auth_repository_impl.dart';
import 'auth/presentation/esqueci_senha_cubit.dart';
import 'auth/presentation/login_cubit.dart';
import 'auth/presentation/recriar_senha_cubit.dart';
import 'auth/presentation/verificar_codigo_cubit.dart';
import 'aplicacoes/core/aplicador_ponto_de_aplicacao_repository.dart';
import 'aplicacoes/data/aplicador_ponto_de_aplicacao_repository_impl.dart';
import 'aplicacoes/presentation/meus_pontos_cubit.dart';
import 'aplicacoes/presentation/detalhe_do_ponto_cubit.dart';
import 'aplicacoes/presentation/geolocalizacao_cubit.dart';
import 'aplicacoes/presentation/tela_de_aplicacao_cubit.dart';
import 'inventory/core/insumo_repository.dart';
import 'inventory/core/recebimento_repository.dart';
import 'inventory/data/insumo_repository_impl.dart';
import 'inventory/data/recebimento_repository_impl.dart';
import 'inventory/presentation/inventario_cubit.dart';
import 'inventory/presentation/recebimento_confirmacao_cubit.dart';
import 'inventory/presentation/recebimentos_cubit.dart';
import 'reports/core/denuncia_de_foco_repository.dart';
import 'reports/data/denuncia_de_foco_repository_impl.dart';
import 'reports/presentation/criar_denuncia_de_foco_cubit.dart';
import 'reports/presentation/denuncias_de_foco_cubit.dart';
import '../src/entities/tenant_config.dart';
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
  AplicadorPontoDeAplicacaoRepository buildAplicadorPontoDeAplicacaoRepository() =>
      AplicadorPontoDeAplicacaoRepositoryImpl();
  InsumoRepository buildInsumoRepository() => InsumoRepositoryImpl();
  RecebimentoRepository buildRecebimentoRepository() =>
      RecebimentoRepositoryImpl();
  DenunciaDeFocoRepository buildDenunciaDeFocoRepository() =>
      DenunciaDeFocoRepositoryImpl();

  LoginCubit buildLoginCubit() => LoginCubit(buildAuthRepository());
  EsqueciSenhaCubit buildEsqueciSenhaCubit() =>
      EsqueciSenhaCubit(buildAuthRepository());
  VerificarCodigoCubit buildVerificarCodigoCubit() =>
      VerificarCodigoCubit(buildAuthRepository());
  RecriarSenhaCubit buildRecriarSenhaCubit() =>
      RecriarSenhaCubit(buildAuthRepository());
  MeusPontosCubit buildMeusPontosCubit(String aplicadorId) =>
      MeusPontosCubit(buildAplicadorPontoDeAplicacaoRepository(), aplicadorId);
  DetalheDoPontoDesignadoCubit buildDetalheDoPontoDesignadoCubit(
    String pontoId,
  ) => DetalheDoPontoDesignadoCubit(
    buildAplicadorPontoDeAplicacaoRepository(),
    pontoId,
  );
  GeolocalizacaoCubit buildGeolocalizacaoCubit(String pontoId) =>
      GeolocalizacaoCubit(buildAplicadorPontoDeAplicacaoRepository(), pontoId);
  TelaDeAplicacaoCubit buildTelaDeAplicacaoCubit(String pontoId) =>
      TelaDeAplicacaoCubit(buildAplicadorPontoDeAplicacaoRepository(), pontoId);
  InventarioCubit buildInventarioCubit() =>
      InventarioCubit(buildInsumoRepository(), buildRecebimentoRepository());
  RecebimentosCubit buildRecebimentosCubit() =>
      RecebimentosCubit(buildRecebimentoRepository());
  RecebimentoConfirmacaoCubit buildRecebimentoConfirmacaoCubit({
    String? recebimentoId,
  }) => RecebimentoConfirmacaoCubit(
    buildRecebimentoRepository(),
    recebimentoId: recebimentoId,
  );
  DenunciasDeFocoCubit buildDenunciasDeFocoCubit() =>
      DenunciasDeFocoCubit(buildDenunciaDeFocoRepository());
  CriarDenunciaDeFocoCubit buildCriarDenunciaDeFocoCubit() =>
      CriarDenunciaDeFocoCubit(buildDenunciaDeFocoRepository());

  TenantCubit buildTenantCubit() =>
      TenantCubit(buildTenantRepository(), MbtilesDownloader());
}
