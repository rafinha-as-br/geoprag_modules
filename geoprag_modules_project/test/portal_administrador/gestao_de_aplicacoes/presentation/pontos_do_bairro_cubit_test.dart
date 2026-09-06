import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/admin_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/pontos_do_bairro_cubit.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:geoprag_modules/src/entities/usuario.dart';
import 'package:mocktail/mocktail.dart';

import '../gestao_de_aplicacoes_fixtures.dart';

class MockAdminPontoDeAplicacaoRepository extends Mock
    implements AdminPontoDeAplicacaoRepository {}

class MockAplicadorRepository extends Mock implements AplicadorRepository {}

void main() {
  late MockAdminPontoDeAplicacaoRepository repository;
  late MockAplicadorRepository aplicadorRepository;

  final aplicador = Aplicador(
    id: '1',
    nome: 'João Silva',
    status: UsuarioStatus.ativo,
    dataCriacao: DateTime(2026, 5, 10),
    email: 'joao.silva@email.com',
    cpf: '111.111.111-11',
    dataNascimento: DateTime(1988, 4, 12),
    sexo: 'Masculino',
    telefone: '(47) 99111-1111',
    cep: '89010-000',
    rua: 'Rua das Flores',
    numero: '50',
    bairro: 'Belchior',
    cidade: 'Blumenau',
    uf: 'SC',
  );

  final desativado = pontoDeAplicacao(
    id: 'pa2',
    identificador: '#GAS2',
    nome: 'Córrego Canalizado',
    estado: EstadoPontoDeAplicacao.desativado,
  );

  setUp(() {
    repository = MockAdminPontoDeAplicacaoRepository();
    aplicadorRepository = MockAplicadorRepository();
    when(
      () => aplicadorRepository.listar(),
    ).thenAnswer((_) async => [aplicador]);
  });

  Future<PontosDoBairroCubit> carregar(List<PontoDeAplicacao> pontos) async {
    when(
      () => repository.listarPorBairro('Gasparinho'),
    ).thenAnswer((_) async => pontos);
    final cubit = PontosDoBairroCubit(
      repository,
      aplicadorRepository,
      'Gasparinho',
    );
    await Future<void>.delayed(Duration.zero);
    return cubit;
  }

  test('busca os pontos do bairro recebido e usa o bairro como título',
      () async {
    final cubit = await carregar([pontoDeAplicacao()]);

    expect(cubit.state.title, 'Gasparinho');
    expect(cubit.state.items.single.id, 'pa1');
    verify(() => repository.listarPorBairro('Gasparinho')).called(1);
  });

  test('a tela do bairro mostra também os pontos desativados', () async {
    final cubit = await carregar([pontoDeAplicacao(), desativado]);

    expect(cubit.state.items.map((p) => p.id), ['pa1', 'pa2']);
  });

  test('busca filtra por nome e identificador', () async {
    final cubit = await carregar([pontoDeAplicacao(), desativado]);

    cubit.buscar('canalizado');
    expect(cubit.state.items.map((p) => p.id), ['pa2']);

    cubit.buscar('#GAS1');
    expect(cubit.state.items.map((p) => p.id), ['pa1']);
  });

  test('emite mensagem amigável quando o repositório falha', () async {
    when(
      () => repository.listarPorBairro('Gasparinho'),
    ).thenAnswer((_) async => throw Exception('offline'));

    final cubit = PontosDoBairroCubit(
      repository,
      aplicadorRepository,
      'Gasparinho',
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.errorMessage, isNot(contains('Exception')));
  });
}
