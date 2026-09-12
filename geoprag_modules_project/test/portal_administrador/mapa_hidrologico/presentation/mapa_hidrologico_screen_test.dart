import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/core/corrego_repository.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/bairros_cubit.dart';
import 'package:geoprag_modules/portal_administrador/mapa_hidrologico/presentation/mapa_hidrologico_screen.dart';
import 'package:geoprag_modules/src/widgets/geoprag_map_placeholder.dart';
import 'package:mocktail/mocktail.dart';

class MockCorregoRepository extends Mock implements CorregoRepository {}

void main() {
  testWidgets(
    'usa o GeopragMapPlaceholder consolidado (GEOPRAG-95) como base do mapa '
    'de bairros, mantendo os pins posicionados por cima',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = MockCorregoRepository();
      when(() => repository.listarBairros()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AdminSessionCubit>(
                create: (_) => AdminSessionCubit(),
              ),
              BlocProvider<BairrosCubit>(
                create: (_) => BairrosCubit(repository),
              ),
            ],
            child: const MapaHidrologicoScreen(),
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
        '[Mapa Interativo de Gaspar]\nBairros clicáveis',
      );
      expect(placeholder.icon, isNull);
      expect(placeholder.height, isNull);
    },
  );
}
