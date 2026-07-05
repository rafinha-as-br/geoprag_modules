import '../models/application.dart';

final List<Application> mockApplications = [
  Application(id: 'a1', date: DateTime.now().subtract(const Duration(days: 2)), lat: -26.9328, lng: -48.9554, dosage: 10.5, applicatorId: '1'),
  Application(id: 'a2', date: DateTime.now().subtract(const Duration(days: 16)), lat: -26.9350, lng: -48.9500, dosage: 15.0, applicatorId: '5'), // atrasado
  Application(id: 'a3', date: DateTime.now().subtract(const Duration(days: 5)), lat: -26.9300, lng: -48.9600, dosage: 8.0, applicatorId: '1'),
  Application(id: 'a4', date: DateTime.now().subtract(const Duration(days: 22)), lat: -26.9400, lng: -48.9400, dosage: 12.0, applicatorId: '5'), // super atrasado
  Application(id: 'a5', date: DateTime.now().subtract(const Duration(days: 1)), lat: -26.9200, lng: -48.9700, dosage: 9.5, applicatorId: '1'),
];
