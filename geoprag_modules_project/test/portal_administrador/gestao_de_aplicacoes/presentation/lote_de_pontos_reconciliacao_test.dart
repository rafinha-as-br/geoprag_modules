import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/lote_de_pontos_reconciliacao.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/ponto_de_aplicacao_view_model.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';

PontoDeAplicacaoResumoViewModel _item(
  String id,
  EstadoPontoDeAplicacao estado,
) => PontoDeAplicacaoResumoViewModel(
  id: id,
  identificador: '#$id',
  nome: 'Ponto $id',
  bairro: 'Gasparinho',
  estado: estado,
  aplicadorNome: null,
  execucoesRegistradas: 0,
  quantidadeDeSubpontos: 1,
  ativoSemRegistro: false,
);

void main() {
  group('reconciliarLote', () {
    test('ativar: aceita direcionada e inativa, ignora os demais com motivo', () {
      final selecionados = [
        _item('a', EstadoPontoDeAplicacao.direcionada),
        _item('b', EstadoPontoDeAplicacao.inativa),
        _item('c', EstadoPontoDeAplicacao.enderecada),
        _item('d', EstadoPontoDeAplicacao.ativa),
        _item('e', EstadoPontoDeAplicacao.desativado),
      ];

      final resultado = reconciliarLote(
        acao: AcaoEmLote.ativar,
        selecionados: selecionados,
      );

      expect(resultado.elegiveis.map((i) => i.id), ['a', 'b']);
      expect(resultado.ignorados.map((i) => i.item.id), ['c', 'd', 'e']);
      expect(resultado.ignorados.first.motivo, contains('Endereçada'));
    });

    test('desativar: aceita todos exceto endereçada, direcionada, ativa e inativa não passam por ela — ela mesma aceita esses quatro, só rejeita desativado', () {
      final selecionados = [
        _item('a', EstadoPontoDeAplicacao.enderecada),
        _item('b', EstadoPontoDeAplicacao.direcionada),
        _item('c', EstadoPontoDeAplicacao.ativa),
        _item('d', EstadoPontoDeAplicacao.inativa),
        _item('e', EstadoPontoDeAplicacao.desativado),
      ];

      final resultado = reconciliarLote(
        acao: AcaoEmLote.desativar,
        selecionados: selecionados,
      );

      expect(resultado.elegiveis.map((i) => i.id), ['a', 'b', 'c', 'd']);
      expect(resultado.ignorados.map((i) => i.item.id), ['e']);
    });

    test('atribuirAplicador: só aceita endereçada', () {
      final selecionados = [
        _item('a', EstadoPontoDeAplicacao.enderecada),
        _item('b', EstadoPontoDeAplicacao.direcionada),
      ];

      final resultado = reconciliarLote(
        acao: AcaoEmLote.atribuirAplicador,
        selecionados: selecionados,
      );

      expect(resultado.elegiveis.map((i) => i.id), ['a']);
      expect(resultado.ignorados.map((i) => i.item.id), ['b']);
    });

    test('temElegiveis é falso quando nenhum item passa', () {
      final resultado = reconciliarLote(
        acao: AcaoEmLote.atribuirAplicador,
        selecionados: [_item('a', EstadoPontoDeAplicacao.ativa)],
      );

      expect(resultado.temElegiveis, isFalse);
    });

    test('lista vazia não gera elegíveis nem ignorados', () {
      final resultado = reconciliarLote(
        acao: AcaoEmLote.desativar,
        selecionados: const [],
      );

      expect(resultado.elegiveis, isEmpty);
      expect(resultado.ignorados, isEmpty);
    });
  });
}
