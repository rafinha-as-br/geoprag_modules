import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/widgets/edicao_de_ponto_banner.dart';

void main() {
  group('EdicaoDePontoBanner', () {
    testWidgets('liberada: mostra "Edição liberada"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(child: EdicaoDePontoBanner(liberada: true)),
        ),
      );

      expect(find.text('Edição liberada'), findsOneWidget);
      expect(find.text('Cadastro travado'), findsNothing);
    });

    testWidgets('travada: mostra "Cadastro travado"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(child: EdicaoDePontoBanner(liberada: false)),
        ),
      );

      expect(find.text('Cadastro travado'), findsOneWidget);
      expect(find.text('Edição liberada'), findsNothing);
    });

    testWidgets(
      'travada: não promete que cancelar a aplicação química libera o cadastro',
      (tester) async {
        // O cadastro trava permanentemente assim que existe agendamento —
        // cancelar a aplicação química não remove o agendamento, só cancela
        // datas pendentes (ver PontoDeAplicacao.cancelarAplicacaoQuimica).
        // Uma versão anterior deste banner sugeria esse caminho por engano.
        await tester.pumpWidget(
          const MaterialApp(
            home: Material(child: EdicaoDePontoBanner(liberada: false)),
          ),
        );

        expect(find.textContaining('cancele a aplicação química'), findsNothing);
      },
    );
  });
}
