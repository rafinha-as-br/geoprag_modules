import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/core/admin_navigator.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/ponto_de_aplicacao_view_model.dart';
import 'package:geoprag_modules/portal_administrador/gestao_de_aplicacoes/presentation/widgets/painel_do_dashboard.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminNavigator extends Mock implements AdminNavigator {}

PontoDeAplicacaoResumoViewModel resumo({
  String id = 'pa1',
  String nome = 'Córrego Gasparinho',
  String bairro = 'Gasparinho',
  bool ativoSemRegistro = false,
}) {
  return PontoDeAplicacaoResumoViewModel(
    id: id,
    identificador: '#GAS1',
    nome: nome,
    bairro: bairro,
    estado: EstadoPontoDeAplicacao.ativa,
    aplicadorNome: 'João Silva',
    execucoesRegistradas: 0,
    quantidadeDeSubpontos: 8,
    ativoSemRegistro: ativoSemRegistro,
  );
}

void main() {
  late MockAdminNavigator navigator;

  const cobertura = [
    CoberturaDeBairroViewModel(
      bairro: 'Gasparinho',
      totalDePontos: 3,
      pontosAtivos: 2,
      pontosComAlerta: 1,
    ),
    CoberturaDeBairroViewModel(
      bairro: 'Belchior',
      totalDePontos: 1,
      pontosAtivos: 1,
      pontosComAlerta: 0,
    ),
  ];

  setUp(() {
    navigator = MockAdminNavigator();
  });

  Widget wrap({
    List<PontoDeAplicacaoResumoViewModel> alertas = const [],
    List<CoberturaDeBairroViewModel> coberturas = cobertura,
    bool incluirDesativados = false,
    ValueChanged<bool>? onAlternarIncluirDesativados,
    ValueChanged<EstadoPontoDeAplicacao?>? onFiltrarPorEstado,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AdminNavigatorScope(
          navigator: navigator,
          child: SingleChildScrollView(
            child: PainelDoDashboard(
              alertas: alertas,
              cobertura: coberturas,
              incluirDesativados: incluirDesativados,
              estadoSelecionado: null,
              onBuscar: (_) {},
              onFiltrarPorEstado: onFiltrarPorEstado ?? (_) {},
              onAlternarIncluirDesativados:
                  onAlternarIncluirDesativados ?? (_) {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('sem alerta, o bloco vermelho não aparece', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.textContaining('sem nenhuma aplicação registrada'), findsNothing);
  });

  testWidgets('com alerta, lista os pontos ativos sem registro',
      (tester) async {
    await tester.pumpWidget(
      wrap(alertas: [resumo(nome: 'Córrego Belchior', ativoSemRegistro: true)]),
    );

    expect(
      find.textContaining('1 ponto(s) ativo(s) sem nenhuma aplicação'),
      findsOneWidget,
    );
    expect(find.textContaining('Córrego Belchior'), findsOneWidget);
  });

  testWidgets('cada bairro coberto vira um cartão com a contagem de pontos',
      (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Gasparinho'), findsOneWidget);
    expect(find.text('3 ponto(s) · 2 ativo(s)'), findsOneWidget);
    expect(find.text('Belchior'), findsOneWidget);
  });

  testWidgets('tocar no cartão do bairro abre a listagem daquele bairro',
      (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.text('Belchior'));
    await tester.pump();

    verify(() => navigator.toAplicacaoBairro('Belchior')).called(1);
  });

  testWidgets('o checkbox de desativados começa desmarcado e avisa a mudança',
      (tester) async {
    bool? incluir;
    await tester.pumpWidget(
      wrap(onAlternarIncluirDesativados: (valor) => incluir = valor),
    );

    final checkbox = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile),
    );
    expect(checkbox.value, isFalse);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    expect(incluir, isTrue);
  });

  testWidgets('escolher um estado no filtro devolve o enum correspondente',
      (tester) async {
    EstadoPontoDeAplicacao? escolhido;
    await tester.pumpWidget(
      wrap(onFiltrarPorEstado: (estado) => escolhido = estado),
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Direcionada').last);
    await tester.pumpAndSettle();

    expect(escolhido, EstadoPontoDeAplicacao.direcionada);
  });
}
