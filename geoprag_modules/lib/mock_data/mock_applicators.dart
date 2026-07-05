import '../models/applicator.dart';

final List<Applicator> mockApplicators = [
  Applicator(id: '1', name: 'João Silva', neighborhood: 'Belchior', status: 'aprovado', registeredAt: DateTime(2026, 5, 10)),
  Applicator(id: '2', name: 'Maria Souza', neighborhood: 'Poço Grande', status: 'pendente', registeredAt: DateTime(2026, 7, 1)),
  Applicator(id: '3', name: 'Carlos Lima', neighborhood: 'Gasparinho', status: 'rejeitado', registeredAt: DateTime(2026, 6, 15)),
  Applicator(id: '4', name: 'Ana Costa', neighborhood: 'Santa Terezinha', status: 'bloqueado', registeredAt: DateTime(2026, 4, 20)),
  Applicator(id: '5', name: 'Pedro Alves', neighborhood: 'Macucos', status: 'aprovado', registeredAt: DateTime(2026, 5, 25)),
];
