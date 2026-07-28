import '../core/responsavel_referencia_distribuicao.dart';

/// Responsáveis de campo disponíveis para seleção no formulário de nova
/// distribuição.
///
/// TODO(GEOPRAG-24): hoje replicado localmente em mock; substituir por uma
/// consulta real assim que houver integração com o cadastro de aplicadores
/// (`gestao_de_aplicadores`) ou com o backend.
final List<ResponsavelReferenciaDistribuicao>
mockResponsaveisReferenciaDistribuicao = [
  ResponsavelReferenciaDistribuicao(
    id: '1',
    nome: 'João Silva',
    bairro: 'Belchior',
  ),
  ResponsavelReferenciaDistribuicao(
    id: '2',
    nome: 'Maria Souza',
    bairro: 'Poço Grande',
  ),
  ResponsavelReferenciaDistribuicao(
    id: '3',
    nome: 'Carlos Lima',
    bairro: 'Gasparinho',
  ),
  ResponsavelReferenciaDistribuicao(
    id: '4',
    nome: 'Ana Costa',
    bairro: 'Santa Terezinha',
  ),
  ResponsavelReferenciaDistribuicao(
    id: '5',
    nome: 'Pedro Alves',
    bairro: 'Macucos',
  ),
];
