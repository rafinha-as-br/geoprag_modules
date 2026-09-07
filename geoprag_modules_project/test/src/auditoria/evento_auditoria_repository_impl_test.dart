import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/src/auditoria/evento_auditoria.dart';
import 'package:geoprag_modules/src/auditoria/evento_auditoria_repository_impl.dart';

void main() {
  test(
    'EventoAuditoria rejeita dataHoraRegistro anterior a dataHoraOcorrencia',
    () {
      expect(
        () => EventoAuditoria(
          id: 'ev1',
          pontoAfetadoId: 'pa1',
          tipo: 'ativacao',
          autor: const AutorUsuario(email: 'a@a.com', perfil: 'Administrador'),
          dataHoraOcorrencia: DateTime(2026, 9, 1, 10),
          dataHoraRegistro: DateTime(2026, 9, 1, 9),
        ),
        throwsA(isA<AssertionError>()),
      );
    },
  );

  late EventoAuditoriaRepositoryImpl repository;

  setUp(() {
    repository = EventoAuditoriaRepositoryImpl();
  });

  tearDown(() {
    mockEventosAuditoria.clear();
  });

  EventoAuditoria criarEvento({
    String id = 'ev1',
    String pontoAfetadoId = 'pa1',
    AutorEvento? autor,
    String? loteId,
  }) => EventoAuditoria(
    id: id,
    pontoAfetadoId: pontoAfetadoId,
    tipo: 'ativacao',
    autor:
        autor ??
        const AutorUsuario(
          email: 'admin@gaspar.sc.gov.br',
          perfil: 'Administrador',
        ),
    dataHoraOcorrencia: DateTime(2026, 9, 1, 10),
    dataHoraRegistro: DateTime(2026, 9, 1, 10, 5),
    payload: const {'estadoAnterior': 'direcionada', 'estadoNovo': 'ativa'},
    loteId: loteId,
  );

  test('listarTodos começa vazio', () async {
    expect(await repository.listarTodos(), isEmpty);
  });

  test('registrar acumula eventos em ordem, sem sobrescrever', () async {
    await repository.registrar(criarEvento(id: 'ev1'));
    await repository.registrar(criarEvento(id: 'ev2'));

    final eventos = await repository.listarTodos();

    expect(eventos, hasLength(2));
    expect(eventos[0].id, 'ev1');
    expect(eventos[1].id, 'ev2');
  });

  test('registrar preserva autor, payload e loteId', () async {
    const autor = AutorAplicadorEmCampo(aplicadorId: 'apl1');
    await repository.registrar(criarEvento(autor: autor, loteId: 'lote1'));

    final evento = (await repository.listarTodos()).single;

    expect(evento.autor, isA<AutorAplicadorEmCampo>());
    expect((evento.autor as AutorAplicadorEmCampo).aplicadorId, 'apl1');
    expect(evento.payload['estadoNovo'], 'ativa');
    expect(evento.loteId, 'lote1');
  });

  test(
    'uma nova instância do repositório enxerga os eventos já registrados (mesma lista global)',
    () async {
      await repository.registrar(criarEvento());

      final outraInstancia = EventoAuditoriaRepositoryImpl();

      expect(await outraInstancia.listarTodos(), hasLength(1));
    },
  );
}
