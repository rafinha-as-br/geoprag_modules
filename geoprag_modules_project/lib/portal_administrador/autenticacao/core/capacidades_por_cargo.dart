import '../../../src/permissions/capacidade.dart';
import 'admin_account.dart';

/// Ponto único de verdade de quais [Capacidade]s cada [AdminRole] libera
/// (GEOPRAG-112). Restringir um cargo no futuro é mudar esta linha — nenhuma
/// tela ou checagem espalhada pelo código precisa mudar junto.
///
/// Administrador e Sub-Administrador têm paridade total hoje: o esquema
/// existe para o dia em que isso precisar deixar de ser verdade, não porque
/// já há uma distinção real.
const Map<AdminRole, Set<Capacidade>> capacidadesPorCargo = {
  AdminRole.administrador: _todasAsCapacidades,
  AdminRole.subAdministrador: _todasAsCapacidades,
};

const Set<Capacidade> _todasAsCapacidades = {
  Capacidade.criarPontoAplicacao,
  Capacidade.editarPontoAplicacao,
  Capacidade.cancelarPontoAplicacao,
  Capacidade.atribuirAplicador,
  Capacidade.ativarPontoAplicacao,
  Capacidade.desativarPontoAplicacao,
};
