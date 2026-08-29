import 'autenticacao/core/admin_auth_repository.dart';
import 'autenticacao/core/solicitacao_redefinicao_repository.dart';
import 'autenticacao/data/admin_auth_repository_impl.dart';
import 'autenticacao/data/solicitacao_redefinicao_repository_impl.dart';
import 'autenticacao/presentation/admin_esqueci_senha_cubit.dart';
import 'autenticacao/presentation/admin_login_cubit.dart';
import 'autenticacao/presentation/admin_recriar_senha_cubit.dart';
import 'autenticacao/presentation/admin_session_cubit.dart';
import 'autenticacao/presentation/autorizacao_redefinicao_cubit.dart';
import 'gerenciamento_de_administradores/core/administrador_repository.dart';
import 'gerenciamento_de_administradores/data/administrador_repository_impl.dart';
import 'gerenciamento_de_administradores/presentation/administradores_cubit.dart';
import 'gerenciamento_de_administradores/presentation/criar_administrador_cubit.dart';
import 'gerenciamento_de_administradores/presentation/solicitacoes_promocao_cubit.dart';
import 'gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import 'gerenciamento_de_aplicadores/data/aplicador_repository_impl.dart';
import 'gerenciamento_de_aplicadores/presentation/aplicador_detalhe_cubit.dart';
import 'gerenciamento_de_aplicadores/presentation/aplicadores_cubit.dart';
import 'gerenciamento_de_aplicadores/presentation/criar_aplicador_cubit.dart';
import 'dashboard/core/resumo_geral_repository.dart';
import 'dashboard/data/resumo_geral_repository_impl.dart';
import 'dashboard/presentation/dashboard_geral_cubit.dart';
import 'distributions/core/distribuicao_repository.dart';
import 'distributions/data/distribuicao_repository_impl.dart';
import 'distributions/presentation/cadastro_saida_cubit.dart';
import 'distributions/presentation/distribuicao_detalhe_cubit.dart';
import 'distributions/presentation/distribuicoes_cubit.dart';
import 'inventory_and_bidding/core/produto_repository.dart';
import 'inventory_and_bidding/data/produto_repository_impl.dart';
import 'inventory_and_bidding/presentation/formulas_dosagem_cubit.dart';
import 'inventory_and_bidding/presentation/produto_detalhe_cubit.dart';
import 'inventory_and_bidding/presentation/produtos_cubit.dart';
import 'mapa_hidrologico/core/aplicacao_mapa_repository.dart';
import 'mapa_hidrologico/core/corrego_repository.dart';
import 'mapa_hidrologico/data/aplicacao_mapa_repository_impl.dart';
import 'mapa_hidrologico/data/corrego_repository_impl.dart';
import 'mapa_hidrologico/presentation/aplicacao_mapa_cubit.dart';
import 'mapa_hidrologico/presentation/bairro_detalhe_cubit.dart';
import 'mapa_hidrologico/presentation/bairros_cubit.dart';
import 'mapa_hidrologico/presentation/corrego_detalhe_cubit.dart';
import 'reports_management/core/denuncia_repository.dart';
import 'reports_management/data/denuncia_repository_impl.dart';
import 'reports_management/presentation/denuncia_detalhe_cubit.dart';
import 'reports_management/presentation/listagem_denuncias_controller.dart';
import 'reports_management/presentation/triagem_denuncias_controller.dart';
import '../src/entities/tenant_config.dart';
import 'tenant/data/tenant_repository_impl.dart';
import 'tenant/presentation/tenant_cubit.dart';

/// DI manual do `portal_administrador`: fábricas que resolvem a instância
/// concreta dos repositórios para cada Bloc/Cubit. Cada `GoRoute.builder`
/// (ver `main.dart` do app) chama a fábrica correspondente ao montar o
/// `BlocProvider` da tela — nunca um `MultiBlocProvider` global.
class AdminBootstrap {
  const AdminBootstrap();

  AdminAuthRepository buildAdminAuthRepository() => AdminAuthRepositoryImpl();
  TenantRepository buildTenantRepository() => AdminTenantRepositoryImpl();
  SolicitacaoRedefinicaoRepository buildSolicitacaoRedefinicaoRepository() =>
      SolicitacaoRedefinicaoRepositoryImpl();
  AplicadorRepository buildAplicadorRepository() => AplicadorRepositoryImpl();
  AdministradorRepository buildAdministradorRepository() =>
      AdministradorRepositoryImpl();
  ResumoGeralRepository buildResumoGeralRepository() =>
      ResumoGeralRepositoryImpl();
  DistribuicaoRepository buildDistribuicaoRepository() =>
      DistribuicaoRepositoryImpl();
  ProdutoRepository buildProdutoRepository() => ProdutoRepositoryImpl();
  CorregoRepository buildCorregoRepository() => CorregoRepositoryImpl();
  AplicacaoMapaRepository buildAplicacaoMapaRepository() =>
      AplicacaoMapaRepositoryImpl();
  DenunciaRepository buildDenunciaRepository() => DenunciaRepositoryImpl();

  AdminLoginCubit buildAdminLoginCubit() =>
      AdminLoginCubit(buildAdminAuthRepository());
  AdminEsqueciSenhaCubit buildAdminEsqueciSenhaCubit() =>
      AdminEsqueciSenhaCubit(buildAdminAuthRepository());
  AdminRecriarSenhaCubit buildAdminRecriarSenhaCubit() =>
      AdminRecriarSenhaCubit(buildAdminAuthRepository());
  AutorizacaoRedefinicaoCubit buildAutorizacaoRedefinicaoCubit() =>
      AutorizacaoRedefinicaoCubit(buildSolicitacaoRedefinicaoRepository());
  AplicadoresCubit buildAplicadoresCubit() =>
      AplicadoresCubit(buildAplicadorRepository());
  AplicadorDetalheCubit buildAplicadorDetalheCubit(String aplicadorId) =>
      AplicadorDetalheCubit(buildAplicadorRepository(), aplicadorId);
  CriarAplicadorCubit buildCriarAplicadorCubit() =>
      CriarAplicadorCubit(buildAplicadorRepository());
  CriarAdministradorCubit buildCriarAdministradorCubit() =>
      CriarAdministradorCubit(buildAdministradorRepository());
  AdministradoresCubit buildAdministradoresCubit() =>
      AdministradoresCubit(buildAdministradorRepository());
  SolicitacoesPromocaoCubit buildSolicitacoesPromocaoCubit(
    String usuarioAtualEmail,
  ) => SolicitacoesPromocaoCubit(
    buildAdministradorRepository(),
    usuarioAtualEmail,
  );
  DashboardGeralCubit buildDashboardGeralCubit() =>
      DashboardGeralCubit(buildResumoGeralRepository());
  DistribuicoesCubit buildDistribuicoesCubit() =>
      DistribuicoesCubit(buildDistribuicaoRepository());
  DistribuicaoDetalheCubit buildDistribuicaoDetalheCubit(
    String distribuicaoId,
  ) => DistribuicaoDetalheCubit(buildDistribuicaoRepository(), distribuicaoId);
  CadastroSaidaCubit buildCadastroSaidaCubit() =>
      CadastroSaidaCubit(buildDistribuicaoRepository());
  ProdutosCubit buildProdutosCubit() => ProdutosCubit(buildProdutoRepository());
  ProdutoDetalheCubit buildProdutoDetalheCubit(String produtoId) =>
      ProdutoDetalheCubit(buildProdutoRepository(), produtoId);
  FormulasDosagemCubit buildFormulasDosagemCubit() =>
      FormulasDosagemCubit(buildProdutoRepository());
  BairrosCubit buildBairrosCubit() => BairrosCubit(buildCorregoRepository());
  BairroDetalheCubit buildBairroDetalheCubit(String bairroId) =>
      BairroDetalheCubit(buildCorregoRepository(), bairroId);
  CorregoDetalheCubit buildCorregoDetalheCubit(String corregoId) =>
      CorregoDetalheCubit(buildCorregoRepository(), corregoId);
  AplicacaoMapaCubit buildAplicacaoMapaCubit(String aplicacaoId) =>
      AplicacaoMapaCubit(buildAplicacaoMapaRepository(), aplicacaoId);
  TriagemDenunciasController buildTriagemDenunciasController() =>
      TriagemDenunciasController(buildDenunciaRepository());
  ListagemDenunciasController buildListagemDenunciasController() =>
      ListagemDenunciasController(buildDenunciaRepository());
  DenunciaDetalheCubit buildDenunciaDetalheCubit(String denunciaId) =>
      DenunciaDetalheCubit(buildDenunciaRepository(), denunciaId);

  AdminTenantCubit buildTenantCubit() =>
      AdminTenantCubit(buildTenantRepository());

  /// Sessão do administrador logado (GEOPRAG-36) — mesma exceção de escopo
  /// raiz do [buildTenantCubit], ver `AdminSessionCubit`.
  AdminSessionCubit buildAdminSessionCubit() => AdminSessionCubit();
}
