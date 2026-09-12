import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia_repository.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/listagem_denuncias_controller.dart';
import 'package:mocktail/mocktail.dart';

class MockDenunciaRepository extends Mock implements DenunciaRepository {}

void main() {
  late MockDenunciaRepository repository;

  final denuncia = Denuncia(
    id: 'r1',
    lat: -26.9328,
    lng: -48.9554,
    nivelInfestacao: 'Alto',
    descricao: 'Muitos borrachudos na varanda',
    status: 'Recebida',
    dataHora: DateTime(2026, 7, 5, 14, 30),
    denunciante: 'João Silva (Voluntário Belchior)',
    observacoes: 'Muita espuma natural no córrego.',
  );

  setUp(() {
    repository = MockDenunciaRepository();
    when(() => repository.listar()).thenAnswer((_) async => [denuncia]);
  });

  test('carrega as denúncias mapeadas para ViewModel', () async {
    final controller = ListagemDenunciasController(repository);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.items.single.id, 'r1');
  });

  test(
    'emite mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    () async {
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => throw Exception('offline'));

      final controller = ListagemDenunciasController(repository);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.errorMessage, isNot(contains('Exception')));
    },
  );
}
