import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/distribuicao_repository.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/produto_referencia_distribuicao.dart';
import 'package:geoprag_modules/portal_administrador/distributions/core/responsavel_referencia_distribuicao.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/cadastro_saida_cubit.dart';
import 'package:geoprag_modules/portal_administrador/distributions/presentation/cadastro_saida_state.dart';
import 'package:mocktail/mocktail.dart';

class MockDistribuicaoRepository extends Mock implements DistribuicaoRepository {}

void main() {
  late MockDistribuicaoRepository repository;

  setUp(() {
    repository = MockDistribuicaoRepository();
  });

  blocTest<CadastroSaidaCubit, CadastroSaidaState>(
    'emite [Loaded] com as opções de produtos e responsáveis mapeadas',
    setUp: () {
      when(() => repository.listarProdutosDisponiveis()).thenAnswer(
        (_) async => const [
          ProdutoReferenciaDistribuicao(id: 'p1', nomeExibicao: 'BTI Líquido'),
        ],
      );
      when(() => repository.listarResponsaveisDisponiveis()).thenAnswer(
        (_) async => const [
          ResponsavelReferenciaDistribuicao(id: '1', nome: 'João Silva', bairro: 'Belchior'),
        ],
      );
    },
    build: () => CadastroSaidaCubit(repository),
    expect: () => [
      isA<CadastroSaidaLoaded>()
          .having((s) => s.produtos.single.id, 'produtos.single.id', 'p1')
          .having((s) => s.responsaveis.single.nome, 'responsaveis.single.nome', 'João Silva'),
    ],
  );

  blocTest<CadastroSaidaCubit, CadastroSaidaState>(
    'emite [Error] com mensagem amigável quando falha ao carregar as opções '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.listarProdutosDisponiveis()).thenThrow(Exception('offline'));
      when(() => repository.listarResponsaveisDisponiveis()).thenAnswer((_) async => []);
    },
    build: () => CadastroSaidaCubit(repository),
    expect: () => [
      isA<CadastroSaidaError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
