import 'package:flutter_test/flutter_test.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/posicao_gps.dart';
import 'package:geoprag_modules/aplicador_app/aplicacoes/core/regra_de_chegada.dart';
import 'package:geoprag_modules/src/entities/ponto_de_aplicacao.dart';

void main() {
  const latitude = -26.9331;
  const longitude = -48.9528;

  // 1 grau de latitude ≈ 111,195 km.
  const metrosPorGrauDeLatitude = 111195.0;

  final primeiroSubponto = Subponto(
    id: 'sp1',
    latitude: latitude,
    longitude: longitude,
    realizadoEm: DateTime(2026, 10, 1),
    registradoEm: DateTime(2026, 10, 1),
  );

  PosicaoGps aMetros(double metrosAoNorte) => PosicaoGps(
    latitude: latitude + metrosAoNorte / metrosPorGrauDeLatitude,
    longitude: longitude,
    precisaoMetros: 5,
    instante: DateTime(2026, 10, 21),
  );

  group('RegraDeChegada.distanciaEmMetros', () {
    test('é zero para o mesmo ponto', () {
      expect(
        RegraDeChegada.distanciaEmMetros(
          latitude,
          longitude,
          latitude,
          longitude,
        ),
        0,
      );
    });

    test('mede cerca de 111 km por grau de latitude', () {
      expect(
        RegraDeChegada.distanciaEmMetros(0, 0, 1, 0),
        closeTo(metrosPorGrauDeLatitude, 200),
      );
    });

    test('é simétrica', () {
      final ida = RegraDeChegada.distanciaEmMetros(
        latitude,
        longitude,
        -26.9,
        -48.9,
      );
      final volta = RegraDeChegada.distanciaEmMetros(
        -26.9,
        -48.9,
        latitude,
        longitude,
      );
      expect(ida, closeTo(volta, 1e-6));
    });
  });

  group('RegraDeChegada.avaliar', () {
    test('o raio provisório é de 100 m (constante única)', () {
      expect(RegraDeChegada.raioDeChegadaMetros, 100);
    });

    test('primeira aplicação (sem subponto) não valida a chegada', () {
      final resultado = RegraDeChegada.avaliar(
        atual: aMetros(5000),
        primeiroSubponto: null,
      );

      expect(resultado, isA<SemValidacaoDeChegada>());
    });

    test('a 40 m do primeiro subponto está dentro do raio', () {
      final resultado = RegraDeChegada.avaliar(
        atual: aMetros(40),
        primeiroSubponto: primeiroSubponto,
      );

      expect(resultado, isA<DentroDoRaio>());
      expect((resultado as DentroDoRaio).distanciaMetros, closeTo(40, 1));
    });

    test('exatamente no raio (100 m) ainda está dentro', () {
      final resultado = RegraDeChegada.avaliar(
        atual: aMetros(RegraDeChegada.raioDeChegadaMetros - 0.5),
        primeiroSubponto: primeiroSubponto,
      );

      expect(resultado, isA<DentroDoRaio>());
    });

    test('a 101 m do primeiro subponto está fora do raio', () {
      final resultado = RegraDeChegada.avaliar(
        atual: aMetros(101),
        primeiroSubponto: primeiroSubponto,
      );

      expect(resultado, isA<ForaDoRaio>());
      expect((resultado as ForaDoRaio).distanciaMetros, closeTo(101, 1));
    });

    test('a referência é só o primeiro subponto, não os seguintes', () {
      // O segundo subponto (50 m ao norte) não entra na conta: o aplicador a
      // 120 m do primeiro está fora, mesmo estando a 70 m do segundo.
      final resultado = RegraDeChegada.avaliar(
        atual: aMetros(120),
        primeiroSubponto: primeiroSubponto,
      );

      expect(resultado, isA<ForaDoRaio>());
    });
  });
}
