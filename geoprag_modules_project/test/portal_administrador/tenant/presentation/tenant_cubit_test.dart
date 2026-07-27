import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/tenant/presentation/tenant_cubit.dart';
import 'package:geoprag_modules/portal_administrador/tenant/presentation/tenant_state.dart';
import 'package:geoprag_modules/src/entities/tenant_config.dart';
import 'package:mocktail/mocktail.dart';

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
      ).thenThrow(StateError('Tenant "tenant-invalido" não encontrado.'));
    },
    build: () => AdminTenantCubit(repository),
    act: (cubit) => cubit.load('tenant-invalido'),
    expect: () => [
      isA<AdminTenantError>().having(
        (s) => s.message,
        'message',
        isNot(contains('StateError')),
      ),
    ],
  );
}
