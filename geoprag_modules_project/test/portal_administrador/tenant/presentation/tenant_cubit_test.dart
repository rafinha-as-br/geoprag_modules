import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_account.dart';
import 'package:geoprag_modules/portal_administrador/tenant/presentation/tenant_cubit.dart';
import 'package:geoprag_modules/portal_administrador/tenant/presentation/tenant_state.dart';
import 'package:geoprag_modules/src/application/admin_portal_runtime.dart';
import 'package:geoprag_modules/src/core/environment/build_environment.dart';
import 'package:geoprag_modules/src/entities/tenant_config.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';
import 'package:geoprag_modules/src/errors/app_error_messages.dart';

class MockTenantRepository extends Mock implements TenantRepository {}

void main() {
  late MockTenantRepository repository;

  const config = TenantConfig(
    tenantId: 'gaspar-sc',
    cityName: 'Gaspar',
    mapBounds: TenantMapBounds(
      southWestLat: -26.9756,
      southWestLng: -48.9976,
      northEastLat: -26.8814,
      northEastLng: -48.8814,
    ),
    mbtilesUrl: 'https://tiles.geoprag.example/gaspar-sc.mbtiles',
    branding: TenantBranding(
      primaryColorHex: '#0B5E3C',
      logoAssetUrl: 'https://tiles.geoprag.example/gaspar-sc/logo.png',
    ),
  );

  setUp(() {
    repository = MockTenantRepository();
    registerFallbackValue(config);
  });

  tearDown(AdminPortalRuntime.limparConfiguracaoDeTeste);

  blocTest<AdminTenantCubit, AdminTenantState>(
    'sem cache: emite [Ready(config)] após buscar e cachear a configuração',
    setUp: () {
      when(() => repository.readCached()).thenAnswer((_) async => null);
      when(
        () => repository.fetchByTenantId('gaspar-sc'),
      ).thenAnswer((_) async => config);
      when(() => repository.cache(any())).thenAnswer((_) async {});
    },
    build: () => AdminTenantCubit(repository),
    act: (cubit) => cubit.load('gaspar-sc'),
    expect: () => [
      isA<AdminTenantReady>().having(
        (s) => s.config.tenantId,
        'config.tenantId',
        'gaspar-sc',
      ),
    ],
    verify: (_) {
      verify(() => repository.cache(config)).called(1);
    },
  );

  blocTest<AdminTenantCubit, AdminTenantState>(
    'com cache: emite Ready(cached) e depois Ready(fresh) ao revalidar em background',
    setUp: () {
      when(() => repository.readCached()).thenAnswer((_) async => config);
      when(
        () => repository.fetchByTenantId('gaspar-sc'),
      ).thenAnswer((_) async => config);
      when(() => repository.cache(any())).thenAnswer((_) async {});
    },
    build: () => AdminTenantCubit(repository),
    act: (cubit) => cubit.load('gaspar-sc'),
    expect: () => [isA<AdminTenantReady>(), isA<AdminTenantReady>()],
  );

  blocTest<AdminTenantCubit, AdminTenantState>(
    'emite [Error] com mensagem amigável quando fetchByTenantId falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.readCached()).thenAnswer((_) async => null);
      when(
        () => repository.fetchByTenantId('tenant-invalido'),
      ).thenThrow(
        const EntidadeNaoEncontradaException('Tenant "tenant-invalido" não encontrado.'),
      );
    },
    build: () => AdminTenantCubit(repository),
    act: (cubit) => cubit.load('tenant-invalido'),
    expect: () => [
      isA<AdminTenantError>().having(
        (s) => s.message,
        'message',
        'Tenant "tenant-invalido" não encontrado.',
      ),
    ],
  );

  blocTest<AdminTenantCubit, AdminTenantState>(
    'emite [Error] com mensagem genérica (e loga) quando a exceção é '
    'inesperada, sem vazar detalhe técnico',
    setUp: () {
      when(() => repository.readCached()).thenAnswer((_) async => null);
      when(
        () => repository.fetchByTenantId('tenant-instavel'),
      ).thenThrow(Exception('timeout'));
    },
    build: () => AdminTenantCubit(repository),
    act: (cubit) => cubit.load('tenant-instavel'),
    expect: () => [
      isA<AdminTenantError>().having(
        (s) => s.message,
        'message',
        AppErrorMessages.carregamentoGenerico,
      ),
    ],
  );

  test('loadForAccount usa o tenant devolvido no login em homologação',
      () async {
    const configHml = TenantConfig(
      tenantId: 'gaspar-sc-hml',
      cityName: 'Gaspar',
      mapBounds: TenantMapBounds(
        southWestLat: -26.9756,
        southWestLng: -48.9976,
        northEastLat: -26.8814,
        northEastLng: -48.8814,
      ),
      mbtilesUrl: '',
      branding: TenantBranding(primaryColorHex: '#0B5E3C', logoAssetUrl: ''),
    );
    AdminPortalRuntime.configurarParaTeste(
      AdminPortalRuntime(
        environment: GeopragBuildEnvironmentConfig.deValor('homologacao'),
      ),
    );
    when(() => repository.readCached()).thenAnswer((_) async => null);
    when(
      () => repository.fetchByTenantId('gaspar-sc-hml'),
    ).thenAnswer((_) async => configHml);
    when(() => repository.cache(configHml)).thenAnswer((_) async {});
    final conta = AdminAccount(
      id: 'admin-hml',
      tenantId: 'gaspar-sc-hml',
      email: 'admin.hml@gaspar.sc.gov.br',
      nome: 'Admin HML',
      cpf: '123.456.789-00',
      dataNascimento: DateTime(1990, 1, 1),
      sexo: 'Não informado',
      dataCriacao: DateTime(2026, 1, 1),
      role: AdminRole.administrador,
    );
    final cubit = AdminTenantCubit(repository);

    await cubit.loadForAccount(conta);

    expect(
      cubit.state,
      isA<AdminTenantReady>().having(
        (state) => state.config.tenantId,
        'tenantId',
        'gaspar-sc-hml',
      ),
    );
    verify(() => repository.fetchByTenantId('gaspar-sc-hml')).called(1);
    await cubit.close();
  });
}
