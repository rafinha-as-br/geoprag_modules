import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gerenciamento_de_aplicadores/core/aplicador_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/core/admin_ponto_de_aplicacao_repository.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/pontos_de_aplicacao_cubit.dart';
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

  final ativoComExecucao = pontoDeAplicacao(
    id: 'pa1',
    identificador: '#GAS1',
    nome: 'Córrego Gasparinho',
    bairro: 'Gasparinho',
    estado: EstadoPontoDeAplicacao.ativa,
    aplicadorId: '1',
    subpontos: [execucaoDeTeste],
  );
  final ativoSemExecucao = pontoDeAplicacao(
    id: 'pa2',
    identificador: '#BEL1',
    nome: 'Córrego Belchior',
    bairro: 'Belchior',
    estado: EstadoPontoDeAplicacao.ativa,
    aplicadorId: '1',
  );
  final enderecado = pontoDeAplicacao(
    id: 'pa3',
    identificador: '#MAC1',
    nome: 'Córrego Macucos',
    bairro: 'Macucos',
  );
  final desativado = pontoDeAplicacao(
    id: 'pa4',
    identificador: '#GAS2',
    nome: 'Córrego Canalizado',
    bairro: 'Gasparinho',
    estado: EstadoPontoDeAplicacao.desativado,
  );

  setUp(() {
    repository = MockAdminPontoDeAplicacaoRepository();
    aplicadorRepository = MockAplicadorRepository();
    when(() => aplicadorRepository.listar()).thenAnswer((_) async => [aplicador]);
  });

  Future<PontosDeAplicacaoCubit> carregar(List<PontoDeAplicacao> pontos) async {
    when(() => repository.listar()).thenAnswer((_) async => pontos);
    final cubit = PontosDeAplicacaoCubit(repository, aplicadorRepository);
    await Future<void>.delayed(Duration.zero);
    return cubit;
  }

  test('resolve o nome do aplicador responsável a partir do id', () async {
    final cubit = await carregar([ativoComExecucao]);

    expect(cubit.state.items.single.aplicadorNome, 'João Silva');
    expect(cubit.state.isLoading, isFalse);
  });

  test('ponto sem aplicador chega à listagem sem nome resolvido', () async {
    final cubit = await carregar([enderecado]);

    expect(cubit.state.items.single.aplicadorNome, isNull);
  });

  test('desativados ficam fora da listagem por padrão', () async {
    final cubit = await carregar([enderecado, desativado]);

    expect(cubit.state.items.map((p) => p.id), ['pa3']);
  });

  test('o checkbox de incluir desativados traz os desativados de volta',
      () async {
    final cubit = await carregar([enderecado, desativado]);

    cubit.alternarIncluirDesativados(true);

    expect(cubit.state.items.map((p) => p.id), ['pa3', 'pa4']);
  });

  test('filtro por estado restringe a listagem àquele estado', () async {
    final cubit = await carregar([ativoComExecucao, enderecado]);

    cubit.filtrarPorEstado(EstadoPontoDeAplicacao.ativa);

    expect(cubit.state.items.map((p) => p.id), ['pa1']);
  });

  test('busca encontra por nome, identificador ou bairro', () async {
    final cubit = await carregar([ativoComExecucao, enderecado]);

    cubit.buscar('macucos');
    expect(cubit.state.items.map((p) => p.id), ['pa3']);

    cubit.buscar('#GAS1');
    expect(cubit.state.items.map((p) => p.id), ['pa1']);
  });

  test('só o ponto ativo sem execução é marcado como alerta', () async {
    final cubit = await carregar([ativoComExecucao, ativoSemExecucao]);

    final alertas = cubit.state.items.where((p) => p.ativoSemRegistro);
    expect(alertas.map((p) => p.id), ['pa2']);
  });

  test('emite mensagem amigável quando o repositório falha, sem vazar a '
      'exceção bruta', () async {
    when(() => repository.listar()).thenAnswer((_) async => throw Exception('offline'));

    final cubit = PontosDeAplicacaoCubit(repository, aplicadorRepository);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.errorMessage, isNotNull);
    expect(cubit.state.errorMessage, isNot(contains('Exception')));
  });
}
