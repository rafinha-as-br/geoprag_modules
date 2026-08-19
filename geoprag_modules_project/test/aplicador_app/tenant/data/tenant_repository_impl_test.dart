import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/tenant/data/mock_tenant_configs.dart';
import 'package:geoprag_modules/aplicador_app/tenant/data/tenant_repository_impl.dart';
import 'package:geoprag_modules/src/errors/app_exceptions.dart';

void main() {
  late TenantRepositoryImpl repository;

  setUp(() {
    repository = TenantRepositoryImpl();
  });

  test('fetchByTenantId retorna a configuração mockada do tenant existente', () async {
    final config = await repository.fetchByTenantId('gaspar-sc');

    expect(config.tenantId, 'gaspar-sc');
    expect(config.cityName, 'Gaspar');
    expect(config, mockAplicadorTenantConfigs['gaspar-sc']);
  });

  test('fetchByTenantId lança EntidadeNaoEncontradaException para tenant inexistente', () {
    expect(
      () => repository.fetchByTenantId('inexistente'),
      throwsA(isA<EntidadeNaoEncontradaException>()),
    );
  });

  test('readCached retorna null antes de qualquer cache() ser chamado', () async {
    expect(await repository.readCached(), isNull);
  });

  test('cache seguido de readCached retorna a mesma configuração', () async {
    final config = mockAplicadorTenantConfigs['gaspar-sc']!;

    await repository.cache(config);

    expect(await repository.readCached(), config);
  });

  test('cache é isolado por instância (não compartilha estado global)', () async {
    final outraInstancia = TenantRepositoryImpl();
    final config = mockAplicadorTenantConfigs['gaspar-sc']!;

    await repository.cache(config);

    expect(await outraInstancia.readCached(), isNull);
  });
}
