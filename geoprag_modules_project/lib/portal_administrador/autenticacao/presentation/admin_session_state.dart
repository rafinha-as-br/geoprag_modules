import '../core/admin_account.dart';

/// Estado de sessão do usuário administrador autenticado no Portal
/// Administrador — fonte de verdade global de "quem está logado e com qual
/// cargo" (GEOPRAG-36), consultada pelo [SidebarMenu] (ocultação de item de
/// menu) e pelo guard de rota do módulo `gerenciamento_de_administradores`.
sealed class AdminSessionState {
  const AdminSessionState();
}

class AdminSessionSemAcesso extends AdminSessionState {
  const AdminSessionSemAcesso();
}

class AdminSessionAutenticado extends AdminSessionState {
  final AdminAccount conta;
  const AdminSessionAutenticado(this.conta);
}
