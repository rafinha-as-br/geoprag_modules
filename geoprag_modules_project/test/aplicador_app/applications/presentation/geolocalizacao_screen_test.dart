import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/applications/core/aplicacao_repository.dart';
import 'package:geoprag_modules/aplicador_app/applications/presentation/geolocalizacao_cubit.dart';
import 'package:geoprag_modules/aplicador_app/applications/presentation/geolocalizacao_screen.dart';
import 'package:geoprag_modules/src/entities/aplicacao.dart';
import 'package:geoprag_modules/src/widgets/geoprag_map_placeholder.dart';
import 'package:mocktail/mocktail.dart';

class MockAplicacaoRepository extends Mock implements AplicacaoRepository {}

void main() {
  testWidgets(
    'usa o GeopragMapPlaceholder consolidado (GEOPRAG-95) no lugar da '
    'Image.network hardcoded, mantendo o radar de distância sobreposto',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = MockAplicacaoRepository();
      final aplicacao = Aplicacao(
        id: 'a1',
        data: DateTime(2026, 5, 3),
        lat: -26.9328,
        lng: -48.9554,
        dosagem: 10.5,
        aplicadorId: '1',
      );
      when(
        () => repository.buscarAtual('1'),
      ).thenAnswer((_) async => aplicacao);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<GeolocalizacaoCubit>(
            create: (_) => GeolocalizacaoCubit(repository, '1'),
            child: const GeolocalizacaoScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(GeopragMapPlaceholder), findsOneWidget);
      final placeholder = tester.widget<GeopragMapPlaceholder>(
        find.byType(GeopragMapPlaceholder),
      );
      expect(placeholder.message, '[Mapa Interativo]');
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    },
  );
}
