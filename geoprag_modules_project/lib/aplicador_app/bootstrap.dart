import 'package:flutter/widgets.dart';

import '../src/api/api_client.dart';
import '../src/api/api_client_provider.dart';
import 'auth/core/auth_repository.dart';
import 'auth/data/auth_repository_impl.dart';
import 'auth/presentation/aplicador_sessao_cubit.dart';
import 'auth/presentation/esqueci_senha_cubit.dart';
import 'auth/presentation/login_cubit.dart';
import 'auth/presentation/recriar_senha_cubit.dart';
import 'auth/presentation/verificar_codigo_cubit.dart';
import 'aplicacoes/core/aplicador_ponto_de_aplicacao_repository.dart';
import 'aplicacoes/core/registro_de_aplicacao_repository.dart';
import 'aplicacoes/core/servico_de_localizacao.dart';
import 'aplicacoes/data/servico_de_localizacao_geolocator.dart';
import 'aplicacoes/presentation/meus_pontos_cubit.dart';
import 'aplicacoes/presentation/detalhe_do_ponto_cubit.dart';
import 'aplicacoes/presentation/geolocalizacao_cubit.dart';
import 'aplicacoes/presentation/tela_de_aplicacao_cubit.dart';
import 'nucleo_offline.dart';
import 'sincronizacao/core/servico_de_sincronizacao.dart';
import 'sincronizacao/presentation/resumo_da_sincronizacao.dart';
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

  /// Cliente HTTP compartilhado (uma instância por processo, ver
  /// [ApiClientProvider]); a troca dos repositórios mock pelos reais usa este.
  ApiClient buildApiClient() => ApiClientProvider.instancia;

  /// Liga a perda de sessão (refresh recusado) ao app e cria o cliente HTTP.
  /// Chamar uma vez, em `main`, antes de qualquer outra fábrica (GEOPRAG-187).
  void configurarApi({required void Function() aoPerderSessao}) {
    ApiClientProvider.aoPerderSessao = aoPerderSessao;
    buildApiClient();
  }

  /// Abre o núcleo offline (banco SQLite, fila de envio, serviço de
  /// sincronização) e liga os gatilhos de envio. Chamar uma vez, em `main`,
  /// antes de `runApp` e depois de [configurarApi] (GEOPRAG-190). Chamadas
  /// seguintes devolvem o mesmo núcleo.
  Future<void> iniciarNucleoOffline() => NucleoOffline.iniciar();

  /// Registro de aplicações local-first. A mesma instância em todo o app.
  RegistroDeAplicacaoRepository buildRegistroDeAplicacaoRepository() =>
      NucleoOffline.instancia.registro;

  /// Serviço de sincronização (envio da outbox). A mesma instância em todo o
  /// app.
  ServicoDeSincronizacao buildServicoDeSincronizacao() =>
      NucleoOffline.instancia.sincronizacao;

  /// Faixa com os indicadores de sincronização (GEOPRAG-204), para
  /// `MeusPontosScreen(resumoDaSincronizacao: ...)`. Não aparece enquanto o
  /// núcleo offline não estiver aberto.
  Widget buildResumoDaSincronizacao() => const ResumoDaSincronizacao();

  AuthRepository buildAuthRepository() => AuthRepositoryImpl(
    api: buildApiClient(),
    sessao: ApiClientProvider.sessao,
  );
  TenantRepository buildTenantRepository() => TenantRepositoryImpl();

  /// Pontos do aplicador, lidos do banco do aparelho (GEOPRAG-203). Exige o
  /// núcleo offline aberto.
  AplicadorPontoDeAplicacaoRepository
  buildAplicadorPontoDeAplicacaoRepository() => NucleoOffline.instancia.pontos;

  /// GPS real do aparelho (GEOPRAG-191); sem rede.
  ServicoDeLocalizacao buildServicoDeLocalizacao() =>
      ServicoDeLocalizacaoGeolocator();
  InsumoRepository buildInsumoRepository() => InsumoRepositoryImpl();
  RecebimentoRepository buildRecebimentoRepository() =>
      RecebimentoRepositoryImpl();
  DenunciaDeFocoRepository buildDenunciaDeFocoRepository() =>
      DenunciaDeFocoRepositoryImpl();

  /// Sessão do aplicador logado — provida na raiz, ver [AplicadorSessaoCubit].
  AplicadorSessaoCubit buildAplicadorSessaoCubit() =>
      AplicadorSessaoCubit(buildAuthRepository());

  LoginCubit buildLoginCubit() => LoginCubit(buildAuthRepository());
  EsqueciSenhaCubit buildEsqueciSenhaCubit() =>
      EsqueciSenhaCubit(buildAuthRepository());
  VerificarCodigoCubit buildVerificarCodigoCubit() =>
      VerificarCodigoCubit(buildAuthRepository());
  RecriarSenhaCubit buildRecriarSenhaCubit() =>
      RecriarSenhaCubit(buildAuthRepository());
  MeusPontosCubit buildMeusPontosCubit(String aplicadorId) => MeusPontosCubit(
    buildAplicadorPontoDeAplicacaoRepository(),
    aplicadorId,
    sincronizacao: buildServicoDeSincronizacao(),
    aoSincronizar: NucleoOffline.instancia.painel.aoMudar,
  );
  DetalheDoPontoDesignadoCubit buildDetalheDoPontoDesignadoCubit(
    String pontoId,
  ) => DetalheDoPontoDesignadoCubit(
    buildAplicadorPontoDeAplicacaoRepository(),
    pontoId,
  );
  GeolocalizacaoCubit buildGeolocalizacaoCubit(String pontoId) =>
      GeolocalizacaoCubit(
        buildAplicadorPontoDeAplicacaoRepository(),
        buildServicoDeLocalizacao(),
        pontoId,
      );
  TelaDeAplicacaoCubit buildTelaDeAplicacaoCubit(
    String pontoId,
    String aplicadorId,
  ) => TelaDeAplicacaoCubit(
    buildAplicadorPontoDeAplicacaoRepository(),
    buildRegistroDeAplicacaoRepository(),
    buildServicoDeLocalizacao(),
    pontoId,
    aplicadorId,
  );
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
