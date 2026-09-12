import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/dashboard/core/resumo_geral.dart';
import 'package:geoprag_modules/portal_administrador/dashboard/core/resumo_geral_repository.dart';
import 'package:geoprag_modules/portal_administrador/dashboard/presentation/dashboard_geral_cubit.dart';
import 'package:geoprag_modules/portal_administrador/dashboard/presentation/dashboard_geral_screen.dart';
import 'package:geoprag_modules/src/widgets/geoprag_map_placeholder.dart';
import 'package:mocktail/mocktail.dart';

class MockResumoGeralRepository extends Mock implements ResumoGeralRepository {}

void main() {
  testWidgets(
    'usa o GeopragMapPlaceholder consolidado (GEOPRAG-95) na área de mapa '
    'do dashboard, no lugar do Container+Text reimplementado',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = MockResumoGeralRepository();
      when(() => repository.buscar()).thenAnswer(
        (_) async => const ResumoGeral(
          lotesAVencer: 0,
          corregosComAplicacaoAtrasada: 0,
          denunciasAbertas: 0,
          atualizacoesEstoque: [],
          ultimasAplicacoes: [],
          focosRecentes: [],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AdminSessionCubit>(
                create: (_) => AdminSessionCubit(),
              ),
              BlocProvider<DashboardGeralCubit>(
                create: (_) => DashboardGeralCubit(repository),
              ),
            ],
            child: const DashboardGeralScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(GeopragMapPlaceholder), findsOneWidget);
      final placeholder = tester.widget<GeopragMapPlaceholder>(
        find.byType(GeopragMapPlaceholder),
      );
      expect(
        placeholder.message,
        '[Componente de Mapa Aqui]\nExibindo divisas de bairros e\n'
        'marcações espaciais dos focos',
      );
    },
  );
}
