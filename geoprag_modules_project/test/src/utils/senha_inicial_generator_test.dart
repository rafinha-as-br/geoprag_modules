import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/utils/senha_inicial_generator.dart';

void main() {
  group('gerarSenhaInicial', () {
    test('combina data (DDMMAAAA) + iniciais minúsculas + # ', () {
      final senha = gerarSenhaInicial(
        nome: 'João Silva',
        dataNascimento: DateTime(1990, 3, 15),
      );
      expect(senha, '15031990js#');
    });

    test(
      'usa a primeira e a última palavra do nome quando há mais de duas',
      () {
        final senha = gerarSenhaInicial(
          nome: 'Maria Clara de Souza',
          dataNascimento: DateTime(1985, 12, 1),
        );
        expect(senha, '01121985ms#');
      },
    );

    test('repete a inicial quando o nome tem uma única palavra', () {
      final senha = gerarSenhaInicial(
        nome: 'Madonna',
        dataNascimento: DateTime(2000, 1, 5),
      );
      expect(senha, '05012000mm#');
    });

    test('preenche dia e mês com zero à esquerda quando necessário', () {
      final senha = gerarSenhaInicial(
        nome: 'Ana Reis',
        dataNascimento: DateTime(1999, 2, 3),
      );
      expect(senha, '03021999ar#');
    });
  });
}
