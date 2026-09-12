import 'resumo_geral_view_model.dart';

sealed class DashboardGeralState {
  const DashboardGeralState();
}

class DashboardGeralLoading extends DashboardGeralState {
  const DashboardGeralLoading();
}

class DashboardGeralLoaded extends DashboardGeralState {
  final ResumoGeralViewModel resumo;
  const DashboardGeralLoaded(this.resumo);
}

class DashboardGeralError extends DashboardGeralState {
  final String message;
  const DashboardGeralError(this.message);
}
