import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/geoprag_modules.dart';

/// Gerador previsível: `id-1`, `id-2`, …
class _GeradorSequencial implements GeradorDeId {
  int _n = 0;

  @override
  String gerar() => 'id-${++_n}';
}

PontoDeAplicacao _pontoAtivo({
  int quantidade = 2,
  Agendamento? agendamento,
  List<Subponto> subpontos = const [],
}) => PontoDeAplicacao(
  id: 'pa1',
  identificador: '#GAS1',
  nome: 'Córrego Gasparinho',
  bairro: 'Gasparinho',
  endereco: 'Rua Pedro Simon',
  numeroReferencia: 'Em frente ao nº 240',
  descricaoDoTrecho: 'Trecho de 400 m.',
  larguraMetros: 2,
  profundidadeMetros: 0.5,
  velocidadeMetrosPorSegundo: 0.4,
  dosagemMl: 120,
  distanciaEntreSubpontosMetros: 50,
  quantidadeDeSubpontos: quantidade,
  aplicadorId: 'u1',
  estado: EstadoPontoDeAplicacao.ativa,
  agendamento: agendamento,
  subpontos: subpontos,
);

Subponto _subponto(String id) => Subponto(
  id: id,
  latitude: -26.93,
  longitude: -48.95,
  realizadoEm: DateTime(2026, 10, 12, 14, 30),
  registradoEm: DateTime(2026, 10, 12, 14, 31),
);

Agendamento _agendamento(List<StatusDataAgendada> status) => Agendamento(
  dataInicio: DateTime(2026, 10, 5),
  intervaloDias: 7,
  quantidadeRecorrencias: status.length,
  datas: [
    for (var i = 0; i < status.length; i++)
      DataAgendada(
        id: 'd-$i',
        data: DateTime(2026, 10, 5).add(Duration(days: 7 * i)),
        status: status[i],
      ),
  ],
);

void main() {
  group('Subponto', () {
    test('Subponto.novo recebe o id do gerador', () {
      final gerador = _GeradorSequencial();

      final a = Subponto.novo(
        gerador: gerador,
        latitude: 1,
        longitude: 2,
        realizadoEm: DateTime(2026),
        registradoEm: DateTime(2026),
      );
      final b = Subponto.novo(
        gerador: gerador,
        latitude: 1,
        longitude: 2,
        realizadoEm: DateTime(2026),
        registradoEm: DateTime(2026),
      );

      expect(a.id, 'id-1');
      expect(b.id, 'id-2');
    });

    test('com o gerador de produção, o id é um UUID v4', () {
      final s = Subponto.novo(
        gerador: GeradorDeIdUuid(),
        latitude: 0,
        longitude: 0,
        realizadoEm: DateTime(2026),
        registradoEm: DateTime(2026),
      );

      expect(GeradorDeIdUuid.ehUuidV4(s.id), isTrue);
    });
  });

  group('DataAgendada', () {
    test('o id acompanha a data em copyWith (cancelar não muda a identidade)', () {
      final data = DataAgendada(id: 'd-1', data: DateTime(2026, 10, 12));

      final cancelada = data.copyWith(status: StatusDataAgendada.cancelada);

      expect(cancelada.id, 'd-1');
      expect(cancelada.status, StatusDataAgendada.cancelada);
    });

    test('a igualdade considera o id', () {
      final a = DataAgendada(id: 'd-1', data: DateTime(2026, 10, 12));

      expect(a, DataAgendada(id: 'd-1', data: DateTime(2026, 10, 12)));
      expect(a, isNot(DataAgendada(id: 'd-2', data: DateTime(2026, 10, 12))));
    });

    test('Agendamento.gerar dá um id a cada data, vindo do gerador', () {
      final agendamento = Agendamento.gerar(
        dataInicio: DateTime(2026, 10, 5),
        intervaloDias: 7,
        quantidadeRecorrencias: 3,
        geradorDeId: _GeradorSequencial(),
      );

      expect(agendamento.datas.map((d) => d.id), ['id-1', 'id-2', 'id-3']);
      expect(agendamento.datas.every((d) => d.status.name == 'pendente'), isTrue);
    });

    test('sem gerador informado, os ids são UUIDs distintos', () {
      final agendamento = Agendamento.gerar(
        dataInicio: DateTime(2026, 10, 5),
        intervaloDias: 7,
        quantidadeRecorrencias: 4,
      );

      final ids = agendamento.datas.map((d) => d.id).toSet();
      expect(ids.length, 4);
      expect(ids.every(GeradorDeIdUuid.ehUuidV4), isTrue);
    });
  });

  group('Aplicacao (append-only)', () {
    Aplicacao nova(GeradorDeId gerador) => Aplicacao.nova(
      gerador: gerador,
      pontoId: 'pa1',
      aplicadorId: 'u1',
      dataAgendadaId: 'd-0',
      produtoId: 'pr-1',
      realizadoEm: DateTime(2026, 10, 12, 14, 30),
      localizacao: const LocalizacaoCapturada(latitude: -26.93, longitude: -48.95),
    );

    test('nasce com id do gerador e sem subpontos', () {
      final aplicacao = nova(_GeradorSequencial());

      expect(aplicacao.id, 'id-1');
      expect(aplicacao.pontoId, 'pa1');
      expect(aplicacao.aplicadorId, 'u1');
      expect(aplicacao.dataAgendadaId, 'd-0');
      expect(aplicacao.produtoId, 'pr-1');
      expect(aplicacao.subpontos, isEmpty);
    });

    test('com o gerador de produção, o id é UUID v4', () {
      expect(GeradorDeIdUuid.ehUuidV4(nova(GeradorDeIdUuid()).id), isTrue);
    });

    test('comSubponto devolve outra aplicação e não altera a original', () {
      final original = nova(_GeradorSequencial());

      final com1 = original.comSubponto(_subponto('s1'));
      final com2 = com1.comSubponto(_subponto('s2'));

      expect(original.subpontos, isEmpty);
      expect(com1.subpontos.map((s) => s.id), ['s1']);
      expect(com2.subpontos.map((s) => s.id), ['s1', 's2']);
      expect(com2.id, original.id);
      expect(identical(com1, original), isFalse);
    });

    test('a lista de subpontos não pode ser alterada por fora', () {
      final aplicacao = nova(_GeradorSequencial()).comSubponto(_subponto('s1'));

      expect(() => aplicacao.subpontos.add(_subponto('s2')), throwsUnsupportedError);
      expect(() => aplicacao.subpontos.removeAt(0), throwsUnsupportedError);
      expect(() => aplicacao.subpontos.clear(), throwsUnsupportedError);
    });

    test('a lista informada no construtor é copiada', () {
      final origem = [_subponto('s1')];
      final aplicacao = Aplicacao(
        id: 'a1',
        pontoId: 'pa1',
        aplicadorId: 'u1',
        dataAgendadaId: 'd-0',
        produtoId: 'pr-1',
        realizadoEm: DateTime(2026),
        localizacao: const LocalizacaoCapturada(latitude: 0, longitude: 0),
        subpontos: origem,
      );

      origem.add(_subponto('s2'));

      expect(aplicacao.subpontos.length, 1);
    });
  });

  group('PontoDeAplicacao.comSubpontoRegistrado', () {
    test('acrescenta o subponto ao fim do histórico', () {
      final ponto = _pontoAtivo(subpontos: [_subponto('s1')]);

      final novo = ponto.comSubpontoRegistrado(_subponto('s2'));

      expect(novo.subpontos.map((s) => s.id), ['s1', 's2']);
      expect(ponto.subpontos.length, 1);
    });

    test('não dá baixa na data enquanto a aplicação não se completa', () {
      final ponto = _pontoAtivo(
        quantidade: 3,
        agendamento: _agendamento([
          StatusDataAgendada.pendente,
          StatusDataAgendada.pendente,
        ]),
      );

      final novo = ponto
          .comSubpontoRegistrado(_subponto('s1'))
          .comSubpontoRegistrado(_subponto('s2'));

      expect(
        novo.agendamento!.datas.map((d) => d.status),
        [StatusDataAgendada.pendente, StatusDataAgendada.pendente],
      );
    });

    test('ao completar a aplicação, a data pendente mais antiga vira concluída', () {
      final ponto = _pontoAtivo(
        quantidade: 2,
        agendamento: _agendamento([
          StatusDataAgendada.concluida,
          StatusDataAgendada.pendente,
          StatusDataAgendada.pendente,
        ]),
      );

      final novo = ponto
          .comSubpontoRegistrado(_subponto('s1'))
          .comSubpontoRegistrado(_subponto('s2'));

      expect(novo.agendamento!.datas.map((d) => d.status), [
        StatusDataAgendada.concluida,
        StatusDataAgendada.concluida,
        StatusDataAgendada.pendente,
      ]);
      expect(novo.agendamento!.datas.map((d) => d.id), ['d-0', 'd-1', 'd-2']);
    });

    test('cada aplicação completa dá baixa numa data (ciclo concluído ao fim)', () {
      var ponto = _pontoAtivo(
        quantidade: 1,
        agendamento: _agendamento([
          StatusDataAgendada.pendente,
          StatusDataAgendada.pendente,
        ]),
      );

      ponto = ponto.comSubpontoRegistrado(_subponto('s1'));
      expect(ponto.cicloConcluido, isFalse);
      ponto = ponto.comSubpontoRegistrado(_subponto('s2'));

      expect(ponto.cicloConcluido, isTrue);
    });

    test('data cancelada não é reaberta nem concluída', () {
      final ponto = _pontoAtivo(
        quantidade: 1,
        agendamento: _agendamento([
          StatusDataAgendada.cancelada,
          StatusDataAgendada.pendente,
        ]),
      );

      final novo = ponto.comSubpontoRegistrado(_subponto('s1'));

      expect(novo.agendamento!.datas.map((d) => d.status), [
        StatusDataAgendada.cancelada,
        StatusDataAgendada.concluida,
      ]);
    });

    test('sem data pendente ou sem agendamento, só o histórico cresce', () {
      final semAgendamento = _pontoAtivo(quantidade: 1)
          .comSubpontoRegistrado(_subponto('s1'));
      final semPendente = _pontoAtivo(
        quantidade: 1,
        agendamento: _agendamento([StatusDataAgendada.concluida]),
      ).comSubpontoRegistrado(_subponto('s1'));

      expect(semAgendamento.agendamento, isNull);
      expect(semAgendamento.subpontos.length, 1);
      expect(semPendente.agendamento!.datas.single.status,
          StatusDataAgendada.concluida);
      expect(semPendente.subpontos.length, 1);
    });
  });
}
