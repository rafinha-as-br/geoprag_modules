import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia_repository.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/denuncias_cubit.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/denuncias_state.dart';
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
  });

  blocTest<DenunciasCubit, DenunciasState>(
    'emite [Loaded] com as denúncias mapeadas para ViewModel',
    setUp: () {
      when(() => repository.listar()).thenAnswer((_) async => [denuncia]);
    },
    build: () => DenunciasCubit(repository),
    expect: () => [
      isA<DenunciasLoaded>().having(
        (s) => s.denuncias.single.id,
        'denuncias.single.id',
        'r1',
      ),
    ],
  );

  blocTest<DenunciasCubit, DenunciasState>(
    'emite [Error] com mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.listar()).thenThrow(Exception('offline'));
    },
    build: () => DenunciasCubit(repository),
    expect: () => [
      isA<DenunciasError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
