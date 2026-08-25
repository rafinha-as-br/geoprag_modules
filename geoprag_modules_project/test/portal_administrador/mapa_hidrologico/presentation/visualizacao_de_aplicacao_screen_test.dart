import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/aplicacao_mapa_repository.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/aplicacao_mapa_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/visualizacao_de_aplicacao_screen.dart';
import 'package:geoprag_modules/src/entities/aplicacao.dart';
import 'package:geoprag_modules/src/widgets/geoprag_map_placeholder.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicacaoMapaRepository extends Mock
    implements AplicacaoMapaRepository {}

void main() {
  testWidgets(
    'usa o GeopragMapPlaceholder consolidado (GEOPRAG-95) para o ponto da '
    'aplicação, preservando mensagem, ícone e altura originais',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = MockAplicacaoMapaRepository();
      final aplicacao = Aplicacao(
        id: 'a1',
        data: DateTime(2026, 5, 3),
        lat: -26.9328,
        lng: -48.9554,
        dosagem: 10.5,
        aplicadorId: '1',
      );
      when(
        () => repository.buscarPorId('a1'),
      ).thenAnswer((_) async => aplicacao);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AdminSessionCubit>(
                create: (_) => AdminSessionCubit(),
              ),
              BlocProvider<AplicacaoMapaCubit>(
                create: (_) => AplicacaoMapaCubit(repository, 'a1'),
              ),
            ],
            child: const VisualizacaoDeAplicacaoScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(GeopragMapPlaceholder), findsOneWidget);
      final placeholder = tester.widget<GeopragMapPlaceholder>(
        find.byType(GeopragMapPlaceholder),
      );
      expect(placeholder.message, '[Mapa Interativo]\nPonto da aplicação');
      expect(placeholder.icon, Icons.location_on);
      expect(placeholder.height, 260);
    },
  );
}
