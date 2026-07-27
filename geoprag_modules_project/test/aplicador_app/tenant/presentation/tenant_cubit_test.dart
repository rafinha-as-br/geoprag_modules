import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/tenant/data/mbtiles_downloader.dart';
import 'package:geoprag_modules/aplicador_app/tenant/presentation/tenant_cubit.dart';
import 'package:geoprag_modules/aplicador_app/tenant/presentation/tenant_state.dart';
import 'package:geoprag_modules/src/entities/tenant_config.dart';
import 'package:mocktail/mocktail.dart';

class MockTenantRepository extends Mock implements TenantRepository {}

class MockMbtilesDownloader extends Mock implements MbtilesDownloader {}

void main() {
  late MockTenantRepository repository;
  late MockMbtilesDownloader downloader;

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
    downloader = MockMbtilesDownloader();
    registerFallbackValue(config);
  });

  blocTest<TenantCubit, TenantState>(
    'sem cache: baixa o mbtiles e emite [Downloading..., Ready(config)]',
    setUp: () {
      when(() => repository.readCached()).thenAnswer((_) async => null);
      when(
        () => repository.fetchByTenantId('gaspar-sc'),
      ).thenAnswer((_) async => config);
      when(
        () => downloader.download(config.mbtilesUrl),
      ).thenAnswer((_) => Stream.fromIterable([0.5, 1.0]));
      when(() => repository.cache(any())).thenAnswer((_) async {});
    },
    build: () => TenantCubit(repository, downloader),
    act: (cubit) => cubit.load('gaspar-sc'),
    expect: () => [
      const TenantDownloading(0.5),
      const TenantDownloading(1.0),
      isA<TenantReady>().having((s) => s.config.tenantId, 'config.tenantId', 'gaspar-sc'),
    ],
    verify: (_) {
      verify(() => repository.cache(config)).called(1);
    },
  );

  blocTest<TenantCubit, TenantState>(
    'com cache: emite Ready(cached) imediatamente e depois atualiza em '
    'background com o resultado fresco (stale-while-revalidate)',
    setUp: () {
      when(() => repository.readCached()).thenAnswer((_) async => config);
      when(
        () => repository.fetchByTenantId('gaspar-sc'),
      ).thenAnswer((_) async => config);
      when(
        () => downloader.download(config.mbtilesUrl),
      ).thenAnswer((_) => Stream.fromIterable([1.0]));
      when(() => repository.cache(any())).thenAnswer((_) async {});
    },
    build: () => TenantCubit(repository, downloader),
    act: (cubit) => cubit.load('gaspar-sc'),
    expect: () => [
      isA<TenantReady>(),
      const TenantDownloading(1.0),
      isA<TenantReady>(),
    ],
  );

  blocTest<TenantCubit, TenantState>(
    'emite [Error] com mensagem amigável quando fetchByTenantId falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.readCached()).thenAnswer((_) async => null);
      when(
        () => repository.fetchByTenantId('tenant-invalido'),
      ).thenThrow(StateError('Tenant "tenant-invalido" não encontrado.'));
    },
    build: () => TenantCubit(repository, downloader),
    act: (cubit) => cubit.load('tenant-invalido'),
    expect: () => [
      isA<TenantError>().having(
        (s) => s.message,
        'message',
        isNot(contains('StateError')),
      ),
    ],
  );
}
