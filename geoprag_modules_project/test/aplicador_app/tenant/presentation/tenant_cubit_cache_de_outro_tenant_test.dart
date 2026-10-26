import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/tenant/data/mbtiles_downloader.dart';
import 'package:geoprag_modules/aplicador_app/tenant/presentation/tenant_cubit.dart';
import 'package:geoprag_modules/aplicador_app/tenant/presentation/tenant_state.dart';
import 'package:geoprag_modules/src/entities/tenant_config.dart';
import 'package:mocktail/mocktail.dart';

class MockTenantRepository extends Mock implements TenantRepository {}

class MockMbtilesDownloader extends Mock implements MbtilesDownloader {}

TenantConfig _config(String tenantId) => TenantConfig(
  tenantId: tenantId,
  cityName: tenantId,
  mapBounds: const TenantMapBounds(
    southWestLat: -26.9756,
    southWestLng: -48.9976,
    northEastLat: -26.8814,
    northEastLng: -48.8814,
  ),
  mbtilesUrl: 'https://tiles.geoprag.example/$tenantId.mbtiles',
  branding: const TenantBranding(
    primaryColorHex: '#0B5E3C',
    logoAssetUrl: 'https://tiles.geoprag.example/logo.png',
  ),
);

void main() {
  late MockTenantRepository repository;
  late MockMbtilesDownloader downloader;

  setUp(() {
    repository = MockTenantRepository();
    downloader = MockMbtilesDownloader();
    registerFallbackValue(_config('qualquer'));
  });

  blocTest<TenantCubit, TenantState>(
    'cache de outro tenant não é emitido: o tenant vem do login e outro '
    'usuário não pode ver a config do anterior',
    setUp: () {
      final nova = _config('nova-cidade');
      when(
        () => repository.readCached(),
      ).thenAnswer((_) async => _config('gaspar-sc'));
      when(
        () => repository.fetchByTenantId('nova-cidade'),
      ).thenAnswer((_) async => nova);
      when(
        () => downloader.download(nova.mbtilesUrl),
      ).thenAnswer((_) => Stream.fromIterable([1.0]));
      when(() => repository.cache(any())).thenAnswer((_) async {});
    },
    build: () => TenantCubit(repository, downloader),
    act: (cubit) => cubit.load('nova-cidade'),
    expect: () => [
      const TenantDownloading(1.0),
      isA<TenantReady>().having(
        (s) => s.config.tenantId,
        'config.tenantId',
        'nova-cidade',
      ),
    ],
  );
}
