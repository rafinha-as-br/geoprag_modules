import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/state/acao_feedback.dart';

void main() {
  group('AcaoFeedback', () {
    test('AcaoFeedbackSucesso carrega a mensagem informada', () {
      const feedback = AcaoFeedbackSucesso('Operação concluída.');

      expect(feedback.mensagem, 'Operação concluída.');
      expect(feedback, isA<AcaoFeedback>());
    });

    test('AcaoFeedbackErro carrega a mensagem informada', () {
      const feedback = AcaoFeedbackErro('Falha ao salvar.');

      expect(feedback.mensagem, 'Falha ao salvar.');
      expect(feedback, isA<AcaoFeedback>());
    });

    test('instâncias do mesmo subtipo com mesma mensagem são iguais', () {
      expect(
        const AcaoFeedbackSucesso('ok'),
        const AcaoFeedbackSucesso('ok'),
      );
      expect(
        const AcaoFeedbackSucesso('ok').hashCode,
        const AcaoFeedbackSucesso('ok').hashCode,
      );
    });

    test('sucesso e erro com a mesma mensagem não são iguais', () {
      expect(
        const AcaoFeedbackSucesso('ok'),
        isNot(equals(const AcaoFeedbackErro('ok'))),
      );
    });

    test('switch exaustivo distingue sucesso de erro', () {
      String describe(AcaoFeedback feedback) => switch (feedback) {
        AcaoFeedbackSucesso() => 'sucesso: ${feedback.mensagem}',
        AcaoFeedbackErro() => 'erro: ${feedback.mensagem}',
      };

      expect(describe(const AcaoFeedbackSucesso('foi')), 'sucesso: foi');
      expect(describe(const AcaoFeedbackErro('não foi')), 'erro: não foi');
    });
  });
}
