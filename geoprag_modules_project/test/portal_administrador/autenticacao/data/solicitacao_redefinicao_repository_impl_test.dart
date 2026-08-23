import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/solicitacao_redefinicao.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/data/mock_solicitacoes_redefinicao.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/data/solicitacao_redefinicao_repository_impl.dart';

void main() {
  late SolicitacaoRedefinicaoRepositoryImpl repository;

  setUp(() {
    repository = SolicitacaoRedefinicaoRepositoryImpl();
  });

  test(
    'buscarPendente retorna a solicitação mockada com status "aguardando"',
    () async {
      final result = await repository.buscarPendente();

      expect(result.id, mockSolicitacaoRedefinicaoPendente.id);
      expect(result.status, StatusSolicitacaoRedefinicao.aguardando);
    },
  );

  test(
    'autorizar muda o status para "autorizado" e persiste na instância',
    () async {
      final result = await repository.autorizar('sr1');

      expect(result.status, StatusSolicitacaoRedefinicao.autorizado);
      expect(
        (await repository.buscarPendente()).status,
        StatusSolicitacaoRedefinicao.autorizado,
      );
    },
  );

  test('negar muda o status para "negado" e persiste na instância', () async {
    final result = await repository.negar('sr1');

    expect(result.status, StatusSolicitacaoRedefinicao.negado);
    expect(
      (await repository.buscarPendente()).status,
      StatusSolicitacaoRedefinicao.negado,
    );
  });

  test('cada instância do repositório mantém estado independente', () async {
    final outraInstancia = SolicitacaoRedefinicaoRepositoryImpl();

    await repository.autorizar('sr1');

    expect(
      (await outraInstancia.buscarPendente()).status,
      StatusSolicitacaoRedefinicao.aguardando,
    );
  });
}
