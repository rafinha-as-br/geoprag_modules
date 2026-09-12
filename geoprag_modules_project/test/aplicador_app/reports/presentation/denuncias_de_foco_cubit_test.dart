import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/reports/core/denuncia_de_foco.dart';
import 'package:geoprag_modules/aplicador_app/reports/core/denuncia_de_foco_repository.dart';
import 'package:geoprag_modules/aplicador_app/reports/presentation/denuncias_de_foco_cubit.dart';
import 'package:geoprag_modules/aplicador_app/reports/presentation/denuncias_de_foco_state.dart';
import 'package:mocktail/mocktail.dart';

class MockDenunciaDeFocoRepository extends Mock implements DenunciaDeFocoRepository {}

void main() {
  late MockDenunciaDeFocoRepository repository;

  final denuncias = [
    DenunciaDeFoco(
      id: '1',
      nivelInfestacao: NivelInfestacaoFoco.alto,
      localDescricao: 'Rua Principal',
      status: StatusDenunciaDeFoco.recebida,
      dataRegistro: DateTime(2026, 7, 5),
    ),
  ];

  setUp(() {
    repository = MockDenunciaDeFocoRepository();
  });

  blocTest<DenunciasDeFocoCubit, DenunciasDeFocoState>(
    'emite [Loaded] com as denúncias mapeadas para ViewModel',
    setUp: () {
      when(() => repository.listar()).thenAnswer((_) async => denuncias);
    },
    build: () => DenunciasDeFocoCubit(repository),
    expect: () => [
      isA<DenunciasDeFocoLoaded>().having(
        (s) => s.denuncias.map((d) => d.id).toList(),
        'ids',
        ['1'],
      ),
    ],
  );

  blocTest<DenunciasDeFocoCubit, DenunciasDeFocoState>(
    'emite [Error] com mensagem amigável quando o repositório falha '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(() => repository.listar()).thenAnswer((_) async => throw Exception('offline'));
    },
    build: () => DenunciasDeFocoCubit(repository),
    expect: () => [
      isA<DenunciasDeFocoError>().having(
        (s) => s.message,
        'message',
        isNot(contains('Exception')),
      ),
    ],
  );
}
