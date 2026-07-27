import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/denuncia_repository.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/core/historico_denuncia.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/denuncia_detalhe_cubit.dart';
import 'package:geoprag_modules/portal_administrador/reports_management/presentation/denuncia_detalhe_state.dart';
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

  const historico = HistoricoDenuncia(
    titulo: 'Criada via App Mobile',
    autor: 'João Silva',
    dataHora: DateTime.fromMillisecondsSinceEpoch(0),
    status: 'Recebida',
  );

  setUp(() {
    repository = MockDenunciaRepository();
  });

  blocTest<DenunciaDetalheCubit, DenunciaDetalheState>(
    'emite [Loaded] com a denúncia e o histórico agregado do id informado',
    setUp: () {
      when(() => repository.buscarPorId('r1')).thenAnswer((_) async => denuncia);
      when(
        () => repository.buscarHistorico('r1'),
      ).thenAnswer((_) async => [historico]);
    },
    build: () => DenunciaDetalheCubit(repository, 'r1'),
    expect: () => [
      isA<DenunciaDetalheLoaded>()
          .having((s) => s.denuncia.id, 'denuncia.id', 'r1')
          .having((s) => s.denuncia.historico, 'denuncia.historico', hasLength(1)),
    ],
  );

  blocTest<DenunciaDetalheCubit, DenunciaDetalheState>(
    'emite [Error] com mensagem amigável quando o id não é encontrado '
    '(nunca expõe a exceção bruta ao usuário)',
    setUp: () {
      when(
        () => repository.buscarPorId('inexistente'),
      ).thenThrow(StateError('Denúncia "inexistente" não encontrada.'));
    },
    build: () => DenunciaDetalheCubit(repository, 'inexistente'),
    expect: () => [
      isA<DenunciaDetalheError>().having(
        (s) => s.message,
        'message',
        isNot(contains('StateError')),
      ),
    ],
  );
}
