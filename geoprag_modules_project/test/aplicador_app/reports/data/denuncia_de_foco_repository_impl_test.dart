import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/reports/core/denuncia_de_foco.dart';
import 'package:geoprag_modules/aplicador_app/reports/data/denuncia_de_foco_repository_impl.dart';
import 'package:geoprag_modules/aplicador_app/reports/data/mock_denuncias_de_foco.dart';

// NOTA: `registrar` insere diretamente em `mockDenunciasDeFoco` (estado
// global em memória). Os testes restauram o tamanho original da lista em
// `tearDown` para não vazar estado entre casos de teste.
void main() {
  late DenunciaDeFocoRepositoryImpl repository;
  late int tamanhoOriginal;

  setUp(() {
    repository = DenunciaDeFocoRepositoryImpl();
    tamanhoOriginal = mockDenunciasDeFoco.length;
  });

  tearDown(() {
    while (mockDenunciasDeFoco.length > tamanhoOriginal) {
      mockDenunciasDeFoco.removeAt(0);
    }
  });

  test('listar retorna todas as denúncias mockadas', () async {
    final result = await repository.listar();
    expect(result.length, tamanhoOriginal);
  });

  test('registrar cria uma nova denúncia com status "recebida" e a insere no topo', () async {
    final nova = await repository.registrar(
      nivelInfestacao: NivelInfestacaoFoco.alto,
      localDescricao: 'Praça Central',
      observacoes: 'Foco próximo à fonte',
    );

    expect(nova.status, StatusDenunciaDeFoco.recebida);
    expect(nova.localDescricao, 'Praça Central');
    expect(nova.observacoes, 'Foco próximo à fonte');

    final listagem = await repository.listar();
    expect(listagem.length, tamanhoOriginal + 1);
    expect(listagem.first.id, nova.id);
  });

  test('registrar aceita observacoes nula', () async {
    final nova = await repository.registrar(
      nivelInfestacao: NivelInfestacaoFoco.baixo,
      localDescricao: 'Beco sem nome',
    );

    expect(nova.observacoes, isNull);
  });
}
