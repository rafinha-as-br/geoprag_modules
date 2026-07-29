import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/core/aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/core/atuacao_aplicador.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicadores/presentation/aplicador_view_model.dart';

void main() {
  final aplicador = Aplicador(
    id: '1',
    nome: 'João Silva',
    bairro: 'Belchior',
    status: 'ativo',
    dataCadastro: DateTime(2026, 5, 10),
    cpf: '111.111.111-11',
    telefone: '(47) 99111-1111',
    endereco: 'Rua das Flores, 50 - Belchior',
  );

  const atuacao = AtuacaoAplicador(
    tipo: AtuacaoAplicadorTipo.aplicacao,
    titulo: 'Aplicação Concluída',
    subtitulo: 'Córrego Gasparinho - 20/06/2026',
    valor: '50ml aplicados',
  );

  group('AplicadorResumoViewModel.fromEntity', () {
    test('mapeia id, nome, bairro e status sem alteração', () {
      final viewModel = AplicadorResumoViewModel.fromEntity(aplicador);

      expect(viewModel.id, '1');
      expect(viewModel.nome, 'João Silva');
      expect(viewModel.bairro, 'Belchior');
      expect(viewModel.status, 'ativo');
    });
  });

  group('AtuacaoAplicadorViewModel.fromEntity', () {
    test('mapeia todos os campos sem alteração', () {
      final viewModel = AtuacaoAplicadorViewModel.fromEntity(atuacao);

      expect(viewModel.tipo, AtuacaoAplicadorTipo.aplicacao);
      expect(viewModel.titulo, 'Aplicação Concluída');
      expect(viewModel.subtitulo, 'Córrego Gasparinho - 20/06/2026');
      expect(viewModel.valor, '50ml aplicados');
    });
  });

  group('AplicadorDetalhadoViewModel.fromEntity', () {
    test('mapeia o perfil e o histórico de atuações', () {
      final viewModel = AplicadorDetalhadoViewModel.fromEntity(aplicador, [atuacao]);

      expect(viewModel.nome, 'João Silva');
      expect(viewModel.cpf, '111.111.111-11');
      expect(viewModel.telefone, '(47) 99111-1111');
      expect(viewModel.endereco, 'Rua das Flores, 50 - Belchior');
      expect(viewModel.status, 'ativo');
      expect(viewModel.historico, hasLength(1));
      expect(viewModel.historico.first.titulo, 'Aplicação Concluída');
    });

    test('historico fica vazio quando não há atuações registradas', () {
      final viewModel = AplicadorDetalhadoViewModel.fromEntity(aplicador, []);
      expect(viewModel.historico, isEmpty);
    });
  });
}
