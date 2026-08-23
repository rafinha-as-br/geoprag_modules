import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/admin_account.dart';
import 'admin_session_state.dart';

/// Cubit de sessão do administrador logado (GEOPRAG-36). Provido na raiz da
/// árvore de widgets do `app_administrador` — mesma exceção deliberada já
/// aplicada ao `AdminTenantCubit` (ver
/// `tenant/presentation/tenant_cubit.dart`): o guard de rota do GoRouter e o
/// `SidebarMenu` precisam saber o cargo atual antes de qualquer tela ser
/// montada, então não pode ser um Cubit escopado por rota.
class AdminSessionCubit extends Cubit<AdminSessionState> {
  AdminSessionCubit() : super(const AdminSessionSemAcesso());

  void iniciarSessao(AdminAccount conta) =>
      emit(AdminSessionAutenticado(conta));

  void encerrarSessao() => emit(const AdminSessionSemAcesso());
}
