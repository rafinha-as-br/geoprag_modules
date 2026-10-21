import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/sincronizacao/sincronizacao.dart';
import 'package:mocktail/mocktail.dart';

class PainelFalso extends Mock implements PainelDeSincronizacao {}

RegistroSincronizavel registro(String id, SituacaoDoRegistro situacao) =>
    RegistroSincronizavel(
      id: id,
      pontoId: 'ponto-1',
      pontoNome: 'Córrego Gasparinho',
      registradoEm: DateTime(2026, 10, 21, 9, 30),
      situacao: situacao,
    );

void main() {
  late PainelFalso painel;
  late StreamController<void> mudancas;

  final pendente = SituacaoDaSincronizacao(
    registros: [registro('s-1', SituacaoDoRegistro.pendente)],
  );
  final enviado = SituacaoDaSincronizacao(
    registros: [registro('s-1', SituacaoDoRegistro.enviado)],
    ultimaSincronizacao: DateTime(2026, 10, 21, 10),
  );

  setUp(() {
    painel = PainelFalso();
    mudancas = StreamController<void>.broadcast();
    when(() => painel.aoMudar).thenAnswer((_) => mudancas.stream);
    when(painel.carregar).thenAnswer((_) async => pendente);
  });

  tearDown(() => mudancas.close());

  blocTest<SincronizacaoCubit, SincronizacaoState>(
    'carrega a situação ao abrir',
    build: () => SincronizacaoCubit(painel),
    expect: () => [isA<SincronizacaoLoaded>()],
    verify: (cubit) {
      final estado = cubit.state as SincronizacaoLoaded;
      expect(estado.situacao.pendentes, 1);
      expect(estado.sincronizando, isFalse);
    },
  );

  test('falha na primeira carga mostra erro amigável', () async {
    when(painel.carregar).thenThrow(StateError('banco fechado'));

    final cubit = SincronizacaoCubit(painel);
    await Future<void>.delayed(Duration.zero);

    expect(
      (cubit.state as SincronizacaoError).message,
      'Não foi possível carregar os dados. Tente novamente.',
    );
    await cubit.close();
  });

  test('atualiza sozinho quando uma sincronização termina', () async {
    final cubit = SincronizacaoCubit(painel);
    await cubit.stream.firstWhere((s) => s is SincronizacaoLoaded);

    when(painel.carregar).thenAnswer((_) async => enviado);
    mudancas.add(null);
    final depois = await cubit.stream.firstWhere(
      (s) => s is SincronizacaoLoaded && s.situacao.pendentes == 0,
    );

    expect(
      (depois as SincronizacaoLoaded).situacao.registros.single.situacao,
      SituacaoDoRegistro.enviado,
    );
    await cubit.close();
  });

  test('falha ao recarregar mantém a lista que já estava na tela', () async {
    final cubit = SincronizacaoCubit(painel);
    await cubit.stream.firstWhere((s) => s is SincronizacaoLoaded);

    when(painel.carregar).thenThrow(StateError('banco ocupado'));
    mudancas.add(null);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<SincronizacaoLoaded>());
    await cubit.close();
  });

  test(
    'carga mais antiga que termina por último não sobrescreve a nova',
    () async {
      final cubit = SincronizacaoCubit(painel);
      await cubit.stream.firstWhere((s) => s is SincronizacaoLoaded);

      final antiga = Completer<SituacaoDaSincronizacao>();
      when(painel.carregar).thenAnswer((_) => antiga.future);
      final cargaAntiga = cubit.carregar();
      when(painel.carregar).thenAnswer((_) async => enviado);
      await cubit.carregar();

      antiga.complete(pendente);
      await cargaAntiga;

      expect((cubit.state as SincronizacaoLoaded).situacao.pendentes, 0);
      await cubit.close();
    },
  );

  test(
    'sincronização automática bem-sucedida limpa o aviso da ação manual',
    () async {
      when(painel.sincronizarAgora).thenAnswer((_) async => false);
      final cubit = SincronizacaoCubit(painel);
      await cubit.stream.firstWhere((s) => s is SincronizacaoLoaded);
      await cubit.sincronizarAgora();
      expect((cubit.state as SincronizacaoLoaded).aviso, isNotNull);

      when(painel.carregar).thenAnswer((_) async => enviado);
      mudancas.add(null);
      await cubit.stream.firstWhere(
        (s) => s is SincronizacaoLoaded && s.aviso == null,
      );

      expect((cubit.state as SincronizacaoLoaded).situacao.pendentes, 0);
      await cubit.close();
    },
  );

  group('sincronizarAgora', () {
    test('liga o indicador, sincroniza e recarrega a lista', () async {
      final espera = Completer<bool>();
      when(painel.sincronizarAgora).thenAnswer((_) => espera.future);
      final cubit = SincronizacaoCubit(painel);
      await cubit.stream.firstWhere((s) => s is SincronizacaoLoaded);

      final acao = cubit.sincronizarAgora();
      expect((cubit.state as SincronizacaoLoaded).sincronizando, isTrue);

      when(painel.carregar).thenAnswer((_) async => enviado);
      espera.complete(true);
      await acao;

      final estado = cubit.state as SincronizacaoLoaded;
      expect(estado.sincronizando, isFalse);
      expect(estado.aviso, isNull);
      expect(estado.situacao.pendentes, 0);
      await cubit.close();
    });

    test(
      'sem conseguir concluir, avisa e mantém o registro pendente',
      () async {
        when(painel.sincronizarAgora).thenAnswer((_) async => false);
        final cubit = SincronizacaoCubit(painel);
        await cubit.stream.firstWhere((s) => s is SincronizacaoLoaded);

        await cubit.sincronizarAgora();

        final estado = cubit.state as SincronizacaoLoaded;
        expect(estado.sincronizando, isFalse);
        expect(estado.aviso, SincronizacaoCubit.avisoSemSincronizar);
        expect(estado.situacao.pendentes, 1);
        await cubit.close();
      },
    );

    test('erro inesperado também vira o aviso e desliga o indicador', () async {
      when(painel.sincronizarAgora).thenThrow(StateError('inesperado'));
      final cubit = SincronizacaoCubit(painel);
      await cubit.stream.firstWhere((s) => s is SincronizacaoLoaded);

      await cubit.sincronizarAgora();

      final estado = cubit.state as SincronizacaoLoaded;
      expect(estado.sincronizando, isFalse);
      expect(estado.aviso, SincronizacaoCubit.avisoSemSincronizar);
      await cubit.close();
    });

    test('não dispara duas sincronizações ao mesmo tempo', () async {
      final espera = Completer<bool>();
      when(painel.sincronizarAgora).thenAnswer((_) => espera.future);
      final cubit = SincronizacaoCubit(painel);
      await cubit.stream.firstWhere((s) => s is SincronizacaoLoaded);

      final primeira = cubit.sincronizarAgora();
      await cubit.sincronizarAgora();
      espera.complete(true);
      await primeira;

      verify(painel.sincronizarAgora).called(1);
      await cubit.close();
    });

    test('uma sincronização nova depois do aviso limpa o aviso', () async {
      when(painel.sincronizarAgora).thenAnswer((_) async => false);
      final cubit = SincronizacaoCubit(painel);
      await cubit.stream.firstWhere((s) => s is SincronizacaoLoaded);
      await cubit.sincronizarAgora();

      when(painel.sincronizarAgora).thenAnswer((_) async => true);
      await cubit.sincronizarAgora();

      expect((cubit.state as SincronizacaoLoaded).aviso, isNull);
      await cubit.close();
    });
  });
}
