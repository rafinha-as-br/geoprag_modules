import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/autenticacao/presentation/admin_session_cubit.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia_repository.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/denuncia_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/visualizacao_individual_denuncia_screen.dart';
import 'package:geoprag_modules/src/widgets/geoprag_map_placeholder.dart';
import 'package:mocktail/mocktail.dart';

class MockDenunciaRepository extends Mock implements DenunciaRepository {}

void main() {
  testWidgets(
    'usa o GeopragMapPlaceholder consolidado (GEOPRAG-95) para o pin GPS da '
    'denúncia, preservando mensagem e altura originais',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = MockDenunciaRepository();
      final denuncia = Denuncia(
        id: 'd1',
        lat: -26.9328,
        lng: -48.9554,
        nivelInfestacao: 'Alto',
        descricao: 'Terreno baldio com água parada',
        status: 'Recebida',
        dataHora: DateTime(2026, 5, 3, 10, 30),
        denunciante: 'Anônimo',
        observacoes: '',
      );
      when(
        () => repository.buscarPorId('d1'),
      ).thenAnswer((_) async => denuncia);
      when(
        () => repository.buscarHistorico('d1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AdminSessionCubit>(
                create: (_) => AdminSessionCubit(),
              ),
              BlocProvider<DenunciaDetalheCubit>(
                create: (_) => DenunciaDetalheCubit(repository, 'd1'),
              ),
            ],
            child: const VisualizacaoIndividualDenunciaScreen(),
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
        '[Mapa estático com Pin GPS: -26.9328, -48.9554]',
      );
      expect(placeholder.height, 150);
    },
  );
}
