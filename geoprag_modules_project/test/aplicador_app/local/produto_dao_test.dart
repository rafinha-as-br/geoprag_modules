import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/local/local.dart';
import 'package:geoprag_modules/src/entities/produto.dart';

import 'apoio_do_banco.dart';

void main() {
  late BancoLocal banco;
  late ProdutoDaoSqflite dao;

  setUp(() async {
    banco = await abrirBancoEmMemoria();
    dao = ProdutoDaoSqflite(banco.db);
  });

  tearDown(() => banco.fechar());

  test('lista vazia enquanto nada foi salvo', () async {
    expect(await dao.listar(), isEmpty);
  });

  test('guarda e lista por nome', () async {
    await dao.salvarTodos(const [
      Produto(id: 'p2', nome: 'Zeta'),
      Produto(id: 'p1', nome: 'alfa'),
    ]);

    expect((await dao.listar()).map((p) => p.id), ['p1', 'p2']);
  });

  test('soma ao que já existe e atualiza o nome do mesmo id', () async {
    await dao.salvarTodos(const [Produto(id: 'p1', nome: 'Larvicida')]);
    await dao.salvarTodos(const [
      Produto(id: 'p1', nome: 'Larvicida B'),
      Produto(id: 'p2', nome: 'Outro'),
    ]);

    expect(await dao.listar(), const [
      Produto(id: 'p1', nome: 'Larvicida B'),
      Produto(id: 'p2', nome: 'Outro'),
    ]);
  });

  test('salvar nada não apaga os produtos', () async {
    await dao.salvarTodos(const [Produto(id: 'p1', nome: 'Larvicida')]);
    await dao.salvarTodos(const []);

    expect(await dao.listar(), hasLength(1));
  });
}
