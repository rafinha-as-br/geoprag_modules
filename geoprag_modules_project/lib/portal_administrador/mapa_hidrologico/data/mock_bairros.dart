import '../core/bairro.dart';

/// Bairros monitorados, agregando o status dos córregos de `mock_corregos.dart`
/// (1 córrego por bairro nos dados mockados atuais).
final List<Bairro> mockBairros = [
  Bairro(
    id: 'b1',
    nome: 'Belchior',
    status: 'atrasado',
    diasSemAplicacao: 25,
    corregoIds: ['s1'],
  ),
  Bairro(
    id: 'b2',
    nome: 'Poço Grande',
    status: 'em_dia',
    diasSemAplicacao: 4,
    corregoIds: ['s2'],
  ),
  Bairro(
    id: 'b3',
    nome: 'Gasparinho',
    status: 'em_dia',
    diasSemAplicacao: 2,
    corregoIds: ['s3'],
  ),
  Bairro(
    id: 'b4',
    nome: 'Macucos',
    status: 'denuncia',
    diasSemAplicacao: 10,
    corregoIds: ['s4'],
  ),
  Bairro(
    id: 'b5',
    nome: 'Santa Terezinha',
    status: 'atrasado',
    diasSemAplicacao: 18,
    corregoIds: ['s5'],
  ),
];
