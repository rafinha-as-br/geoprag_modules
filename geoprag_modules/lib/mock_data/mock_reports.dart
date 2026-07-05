import '../models/report.dart';

final List<Report> mockReports = [
  Report(id: 'r1', lat: -26.9328, lng: -48.9554, infestationLevel: 'Alto', description: 'Muitos borrachudos na varanda', status: 'Recebida'),
  Report(id: 'r2', lat: -26.9350, lng: -48.9500, infestationLevel: 'Médio', description: 'Foco no córrego', status: 'Equipe a Investigar'),
  Report(id: 'r3', lat: -26.9300, lng: -48.9600, infestationLevel: 'Baixo', description: 'Alguns mosquitos à tarde', status: 'Em Combate'),
  Report(id: 'r4', lat: -26.9400, lng: -48.9400, infestationLevel: 'Alto', description: 'Impossível ficar fora de casa', status: 'Resolvido'),
  Report(id: 'r5', lat: -26.9200, lng: -48.9700, infestationLevel: 'Alto', description: 'Nuvem de borrachudos', status: 'Recebida'),
];
