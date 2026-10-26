import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/servico_de_localizacao.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/data/servico_de_localizacao_geolocator.dart';
import 'package:mocktail/mocktail.dart';

class MockGeolocatorPlatform extends Mock implements GeolocatorPlatform {}

void main() {
  late MockGeolocatorPlatform plataforma;
  final agora = DateTime(2026, 10, 21, 10, 15);

  ServicoDeLocalizacaoGeolocator servico() => ServicoDeLocalizacaoGeolocator(
    plataforma: plataforma,
    agora: () => agora,
  );

  Position posicaoDoPlugin() => Position(
    longitude: -48.9528,
    latitude: -26.9331,
    timestamp: DateTime.utc(2026, 10, 21, 13, 15),
    accuracy: 7.5,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  Matcher semPosicaoPor(MotivoSemPosicao motivo) =>
      isA<PosicaoIndisponivelException>().having(
        (e) => e.motivo,
        'motivo',
        motivo,
      );

  setUp(() {
    plataforma = MockGeolocatorPlatform();
    when(
      () => plataforma.isLocationServiceEnabled(),
    ).thenAnswer((_) async => true);
    when(
      () => plataforma.checkPermission(),
    ).thenAnswer((_) async => LocationPermission.whileInUse);
    when(
      () => plataforma.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenAnswer((_) async => posicaoDoPlugin());
  });

  test(
    'devolve latitude, longitude, precisão e o instante do aparelho',
    () async {
      final posicao = await servico().obterPosicao();

      expect(posicao.latitude, -26.9331);
      expect(posicao.longitude, -48.9528);
      expect(posicao.precisaoMetros, 7.5);
      expect(posicao.instante, agora);
    },
  );

  test('pede alta precisão com tempo limite', () async {
    await ServicoDeLocalizacaoGeolocator(
      plataforma: plataforma,
      tempoLimite: const Duration(seconds: 7),
    ).obterPosicao();

    final configuracao =
        verify(
              () => plataforma.getCurrentPosition(
                locationSettings: captureAny(named: 'locationSettings'),
              ),
            ).captured.single
            as LocationSettings;
    expect(configuracao.accuracy, LocationAccuracy.high);
    expect(configuracao.timeLimit, const Duration(seconds: 7));
  });

  test('GPS desligado: não pede permissão nem posição', () async {
    when(
      () => plataforma.isLocationServiceEnabled(),
    ).thenAnswer((_) async => false);

    await expectLater(
      servico().obterPosicao(),
      throwsA(semPosicaoPor(MotivoSemPosicao.servicoDesligado)),
    );

    verifyNever(() => plataforma.requestPermission());
    verifyNever(
      () => plataforma.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    );
  });

  test(
    'permissão negada: pede de novo e, se negada, não lê a posição',
    () async {
      when(
        () => plataforma.checkPermission(),
      ).thenAnswer((_) async => LocationPermission.denied);
      when(
        () => plataforma.requestPermission(),
      ).thenAnswer((_) async => LocationPermission.denied);

      await expectLater(
        servico().obterPosicao(),
        throwsA(semPosicaoPor(MotivoSemPosicao.permissaoNegada)),
      );

      verify(() => plataforma.requestPermission()).called(1);
      verifyNever(
        () => plataforma.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      );
    },
  );

  test('permissão negada e depois concedida no pedido: lê a posição', () async {
    when(
      () => plataforma.checkPermission(),
    ).thenAnswer((_) async => LocationPermission.denied);
    when(
      () => plataforma.requestPermission(),
    ).thenAnswer((_) async => LocationPermission.whileInUse);

    final posicao = await servico().obterPosicao();

    expect(posicao.latitude, -26.9331);
  });

  test(
    'permissão negada para sempre: não pede e orienta pelas configurações',
    () async {
      when(
        () => plataforma.checkPermission(),
      ).thenAnswer((_) async => LocationPermission.deniedForever);

      await expectLater(
        servico().obterPosicao(),
        throwsA(semPosicaoPor(MotivoSemPosicao.permissaoNegadaParaSempre)),
      );

      verifyNever(() => plataforma.requestPermission());
    },
  );

  test('timeout do GPS vira tempo esgotado', () async {
    when(
      () => plataforma.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenThrow(TimeoutException('gps'));

    await expectLater(
      servico().obterPosicao(),
      throwsA(semPosicaoPor(MotivoSemPosicao.tempoEsgotado)),
    );
  });

  test('GPS desligado durante a leitura vira serviço desligado', () async {
    when(
      () => plataforma.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenThrow(const LocationServiceDisabledException());

    await expectLater(
      servico().obterPosicao(),
      throwsA(semPosicaoPor(MotivoSemPosicao.servicoDesligado)),
    );
  });

  test('falha inesperada do plugin vira posição indisponível', () async {
    when(
      () => plataforma.checkPermission(),
    ).thenThrow(StateError('plugin quebrado'));

    await expectLater(
      servico().obterPosicao(),
      throwsA(semPosicaoPor(MotivoSemPosicao.indisponivel)),
    );
  });

  test('permissão revogada durante a leitura vira permissão negada', () async {
    when(
      () => plataforma.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenThrow(const PermissionDeniedException('revogada'));

    await expectLater(
      servico().obterPosicao(),
      throwsA(semPosicaoPor(MotivoSemPosicao.permissaoNegada)),
    );
  });
}
