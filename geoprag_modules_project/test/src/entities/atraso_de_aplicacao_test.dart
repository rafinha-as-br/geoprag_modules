import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/entities/atraso_de_aplicacao.dart';

void main() {
  final prevista = DateTime(2026, 10, 1);

  EstadoDeAtraso verificar(
    DateTime referencia, {
    DateTime? dataPrevista,
    bool semDataPrevista = false,
    int? tolerancia,
    bool aplicacaoConcluida = false,
    bool alertaRemovidoManualmente = false,
  }) {
    final previsto = semDataPrevista ? null : (dataPrevista ?? prevista);
    return tolerancia == null
        ? verificarAtraso(
            dataPrevista: previsto,
            dataDeReferencia: referencia,
            aplicacaoConcluida: aplicacaoConcluida,
            alertaRemovidoManualmente: alertaRemovidoManualmente,
          )
        : verificarAtraso(
            dataPrevista: previsto,
            dataDeReferencia: referencia,
            toleranciaEmDias: tolerancia,
            aplicacaoConcluida: aplicacaoConcluida,
            alertaRemovidoManualmente: alertaRemovidoManualmente,
          );
  }

  group('tolerância padrão', () {
    test('é de 4 dias, em um único lugar', () {
      expect(toleranciaPadraoDeAtrasoEmDias, 4);
    });

    test('é usada quando a tolerância não é informada', () {
      expect(verificar(DateTime(2026, 10, 5)), EstadoDeAtraso.emDia);
      expect(verificar(DateTime(2026, 10, 6)), EstadoDeAtraso.emAtraso);
    });
  });

  group('limites do prazo (tolerância padrão de 4 dias)', () {
    test('antes da data prevista está em dia', () {
      expect(verificar(DateTime(2026, 9, 28)), EstadoDeAtraso.emDia);
    });

    test('na própria data prevista está em dia', () {
      expect(verificar(prevista), EstadoDeAtraso.emDia);
    });

    test('no último dia da tolerância ainda está em dia', () {
      expect(verificar(DateTime(2026, 10, 5)), EstadoDeAtraso.emDia);
    });

    test('um dia depois do último dia da tolerância está em atraso', () {
      expect(verificar(DateTime(2026, 10, 6)), EstadoDeAtraso.emAtraso);
    });

    test('bem depois do prazo continua em atraso', () {
      expect(verificar(DateTime(2026, 11, 20)), EstadoDeAtraso.emAtraso);
    });
  });

  group('tolerância diferente de 4', () {
    test('tolerância 2: em dia até o 2º dia, em atraso no 3º', () {
      expect(
        verificar(DateTime(2026, 10, 3), tolerancia: 2),
        EstadoDeAtraso.emDia,
      );
      expect(
        verificar(DateTime(2026, 10, 4), tolerancia: 2),
        EstadoDeAtraso.emAtraso,
      );
    });

    test('tolerância 7: em dia até o 7º dia, em atraso no 8º', () {
      expect(
        verificar(DateTime(2026, 10, 8), tolerancia: 7),
        EstadoDeAtraso.emDia,
      );
      expect(
        verificar(DateTime(2026, 10, 9), tolerancia: 7),
        EstadoDeAtraso.emAtraso,
      );
    });

    test('tolerância 0: em dia só na data prevista', () {
      expect(verificar(prevista, tolerancia: 0), EstadoDeAtraso.emDia);
      expect(
        verificar(DateTime(2026, 10, 2), tolerancia: 0),
        EstadoDeAtraso.emAtraso,
      );
    });

    test('tolerância negativa lança ArgumentError', () {
      expect(
        () => verificar(DateTime(2026, 10, 2), tolerancia: -1),
        throwsArgumentError,
      );
    });
  });

  group('ponto sem agendamento vigente', () {
    test('não tem data prevista, logo nunca está em atraso', () {
      expect(
        verificar(DateTime(2027, 1, 1), semDataPrevista: true),
        EstadoDeAtraso.emDia,
      );
    });
  });

  group('contagem em dias de calendário', () {
    test('a hora do dia é ignorada', () {
      final previstaTarde = DateTime(2026, 10, 1, 23, 59);
      expect(
        verificar(DateTime(2026, 10, 5, 0, 1), dataPrevista: previstaTarde),
        EstadoDeAtraso.emDia,
      );
      expect(
        verificar(DateTime(2026, 10, 6, 0, 1), dataPrevista: previstaTarde),
        EstadoDeAtraso.emAtraso,
      );
    });

    test('atravessa a virada de mês', () {
      final fimDoMes = DateTime(2026, 10, 29);
      expect(
        verificar(DateTime(2026, 11, 2), dataPrevista: fimDoMes),
        EstadoDeAtraso.emDia,
      );
      expect(
        verificar(DateTime(2026, 11, 3), dataPrevista: fimDoMes),
        EstadoDeAtraso.emAtraso,
      );
    });

    test('atravessa a virada de ano', () {
      final fimDoAno = DateTime(2026, 12, 30);
      expect(
        verificar(DateTime(2027, 1, 3), dataPrevista: fimDoAno),
        EstadoDeAtraso.emDia,
      );
      expect(
        verificar(DateTime(2027, 1, 4), dataPrevista: fimDoAno),
        EstadoDeAtraso.emAtraso,
      );
    });
  });

  group('fim do aviso', () {
    final muitoAtrasado = DateTime(2026, 11, 20);

    test('aplicação concluída (registro tardio) elimina o aviso', () {
      expect(
        verificar(muitoAtrasado, aplicacaoConcluida: true),
        EstadoDeAtraso.emDia,
      );
    });

    test('alerta removido manualmente elimina o aviso', () {
      expect(
        verificar(muitoAtrasado, alertaRemovidoManualmente: true),
        EstadoDeAtraso.emDia,
      );
    });

    test('concluída e removida manualmente juntas também ficam em dia', () {
      expect(
        verificar(
          muitoAtrasado,
          aplicacaoConcluida: true,
          alertaRemovidoManualmente: true,
        ),
        EstadoDeAtraso.emDia,
      );
    });

    test('a próxima recorrência atrasada volta a gerar o aviso', () {
      final proximaPrevista = DateTime(2026, 11, 1);
      expect(
        verificar(
          muitoAtrasado,
          dataPrevista: proximaPrevista,
          alertaRemovidoManualmente: false,
        ),
        EstadoDeAtraso.emAtraso,
      );
    });
  });
}
