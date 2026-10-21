import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../../src/errors/app_logger.dart';
import '../core/posicao_gps.dart';
import '../core/servico_de_localizacao.dart';

/// [ServicoDeLocalizacao] sobre o plugin `geolocator` (GEOPRAG-191).
///
/// Só usa o GPS do aparelho: não depende de rede nem de serviço de mapa
/// online, então a posição vem também em modo avião.
class ServicoDeLocalizacaoGeolocator implements ServicoDeLocalizacao {
  ServicoDeLocalizacaoGeolocator({
    GeolocatorPlatform? plataforma,
    this.tempoLimite = const Duration(seconds: 20),
    DateTime Function()? agora,
  }) : _plataforma = plataforma ?? GeolocatorPlatform.instance,
       _agora = agora ?? DateTime.now;

  final GeolocatorPlatform _plataforma;
  final Duration tempoLimite;
  final DateTime Function() _agora;

  @override
  Future<PosicaoGps> obterPosicao() async {
    try {
      return await _ler();
    } on PosicaoIndisponivelException {
      rethrow;
    } catch (e, stackTrace) {
      // Falha inesperada do plugin: o aplicador recebe a orientação genérica.
      AppLogger.error(
        'ServicoDeLocalizacaoGeolocator.obterPosicao',
        e,
        stackTrace,
      );
      throw const PosicaoIndisponivelException(MotivoSemPosicao.indisponivel);
    }
  }

  Future<PosicaoGps> _ler() async {
    if (!await _plataforma.isLocationServiceEnabled()) {
      throw const PosicaoIndisponivelException(
        MotivoSemPosicao.servicoDesligado,
      );
    }
    var permissao = await _plataforma.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await _plataforma.requestPermission();
    }
    switch (permissao) {
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        throw const PosicaoIndisponivelException(
          MotivoSemPosicao.permissaoNegada,
        );
      case LocationPermission.deniedForever:
        throw const PosicaoIndisponivelException(
          MotivoSemPosicao.permissaoNegadaParaSempre,
        );
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        break;
    }

    try {
      final posicao = await _plataforma.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: tempoLimite,
        ),
      );
      return PosicaoGps(
        latitude: posicao.latitude,
        longitude: posicao.longitude,
        precisaoMetros: posicao.accuracy,
        instante: _agora(),
      );
    } on TimeoutException {
      throw const PosicaoIndisponivelException(MotivoSemPosicao.tempoEsgotado);
    } on LocationServiceDisabledException {
      throw const PosicaoIndisponivelException(
        MotivoSemPosicao.servicoDesligado,
      );
    } on PermissionDeniedException {
      throw const PosicaoIndisponivelException(
        MotivoSemPosicao.permissaoNegada,
      );
    }
  }
}
