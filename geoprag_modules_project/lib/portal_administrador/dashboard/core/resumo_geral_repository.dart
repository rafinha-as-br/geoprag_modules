import 'resumo_geral.dart';

/// Contrato de acesso ao resumo geral operacional do Dashboard do Portal
/// Administrador.
///
/// Um dashboard é um retrato único (snapshot) do estado atual — não há
/// conceito de listagem ou busca por id, apenas uma busca agregada.
///
/// TODO(GEOPRAG-24): contrato real dos endpoints ainda não validado com o
/// backend.
abstract class ResumoGeralRepository {
  Future<ResumoGeral> buscar();
}
