import 'dart:math' as math;

import '../../../src/entities/ponto_de_aplicacao.dart';
import 'posicao_gps.dart';

/// Resultado da validação de chegada ao ponto.
sealed class ResultadoDaChegada {
  const ResultadoDaChegada();
}

/// Primeira aplicação do ponto (ainda sem subponto): a chegada não é validada.
/// A posição capturada no registro passa a ser a referência do ponto.
class SemValidacaoDeChegada extends ResultadoDaChegada {
  const SemValidacaoDeChegada();
}

class DentroDoRaio extends ResultadoDaChegada {
  const DentroDoRaio(this.distanciaMetros);

  final double distanciaMetros;
}

class ForaDoRaio extends ResultadoDaChegada {
  const ForaDoRaio(this.distanciaMetros);

  final double distanciaMetros;
}

/// Validação **provisória** de chegada ao ponto (GEOPRAG-191).
///
/// A distância é medida da posição atual até o **primeiro subponto já
/// registrado** do ponto; o formato e o valor definitivos do raio ainda serão
/// definidos (regra _Georreferenciamento e Validação_).
class RegraDeChegada {
  const RegraDeChegada._();

  /// Raio de chegada, em metros. Valor provisório e único: é o único lugar
  /// onde ele existe.
  static const double raioDeChegadaMetros = 100;

  /// Avalia a chegada de [atual] ao ponto cuja referência é o [primeiroSubponto]
  /// (`null` na primeira aplicação do ponto).
  static ResultadoDaChegada avaliar({
    required PosicaoGps atual,
    required Subponto? primeiroSubponto,
  }) {
    if (primeiroSubponto == null) return const SemValidacaoDeChegada();
    final distancia = distanciaEmMetros(
      atual.latitude,
      atual.longitude,
      primeiroSubponto.latitude,
      primeiroSubponto.longitude,
    );
    return distancia <= raioDeChegadaMetros
        ? DentroDoRaio(distancia)
        : ForaDoRaio(distancia);
  }

  /// Distância em metros entre duas coordenadas (fórmula de haversine).
  static double distanciaEmMetros(
    double latitudeA,
    double longitudeA,
    double latitudeB,
    double longitudeB,
  ) {
    const raioDaTerraMetros = 6371000.0;
    final dLat = _radianos(latitudeB - latitudeA);
    final dLon = _radianos(longitudeB - longitudeA);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_radianos(latitudeA)) *
            math.cos(_radianos(latitudeB)) *
            math.pow(math.sin(dLon / 2), 2);
    return 2 * raioDaTerraMetros * math.asin(math.sqrt(a));
  }

  static double _radianos(double graus) => graus * math.pi / 180;
}
