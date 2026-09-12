import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia_repository.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/triagem_denuncias_controller.dart';
import 'package:mocktail/mocktail.dart';

class MockDenunciaRepository extends Mock implements DenunciaRepository {}

void main() {
  late MockDenunciaRepository repository;

  final denunciaAlta = Denuncia(
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
  final denunciaBaixaResolvida = Denuncia(
    id: 'r2',
    lat: -26.93,
    lng: -48.95,
    nivelInfestacao: 'Baixo',
    descricao: 'Poucos focos no quintal',
    status: 'Resolvido',
    dataHora: DateTime(2026, 7, 6, 9, 0),
    denunciante: 'Maria Souza',
    observacoes: '',
  );

  setUp(() {
    repository = MockDenunciaRepository();
    when(
      () => repository.listar(),
    ).thenAnswer((_) async => [denunciaAlta, denunciaBaixaResolvida]);
  });

  test('carrega as denúncias mapeadas para ViewModel', () async {
    final controller = TriagemDenunciasController(repository);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.items.length, 2);
  });

  test(
    'emite mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    () async {
      when(
        () => repository.listar(),
      ).thenAnswer((_) async => throw Exception('offline'));

      final controller = TriagemDenunciasController(repository);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.errorMessage, isNot(contains('Exception')));
    },
  );
}
