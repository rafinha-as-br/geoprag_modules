import '../core/aplicacao.dart';

final List<Aplicacao> mockApplications = [
  Aplicacao(
    id: 'a1',
    data: DateTime.now().subtract(const Duration(days: 2)),
    lat: -26.9328,
    lng: -48.9554,
    dosagem: 10.5,
    aplicadorId: '1',
  ),
  Aplicacao(
    id: 'a2',
    data: DateTime.now().subtract(const Duration(days: 16)),
    lat: -26.9350,
    lng: -48.9500,
    dosagem: 15.0,
    aplicadorId: '5',
  ), // atrasado
  Aplicacao(
    id: 'a3',
    data: DateTime.now().subtract(const Duration(days: 5)),
    lat: -26.9300,
    lng: -48.9600,
    dosagem: 8.0,
    aplicadorId: '1',
  ),
  Aplicacao(
    id: 'a4',
    data: DateTime.now().subtract(const Duration(days: 22)),
    lat: -26.9400,
    lng: -48.9400,
    dosagem: 12.0,
    aplicadorId: '5',
  ), // super atrasado
  Aplicacao(
    id: 'a5',
    data: DateTime.now().subtract(const Duration(days: 1)),
    lat: -26.9200,
    lng: -48.9700,
    dosagem: 9.5,
    aplicadorId: '1',
  ),
];
