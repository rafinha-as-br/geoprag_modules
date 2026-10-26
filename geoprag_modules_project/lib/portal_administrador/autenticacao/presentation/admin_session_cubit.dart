import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';
import '../../../src/permissions/capacidade.dart';
import '../core/admin_account.dart';
import '../core/admin_auth_repository.dart';
import '../core/capacidades_por_cargo.dart';
import 'admin_session_state.dart';

/// Cubit de sessão do administrador logado (GEOPRAG-36). Provido na raiz da
/// árvore de widgets do `app_administrador` — mesma exceção deliberada já
/// aplicada ao `AdminTenantCubit` (ver
/// `tenant/presentation/tenant_cubit.dart`): o guard de rota do GoRouter e o
/// `SidebarMenu` precisam saber o cargo atual antes de qualquer tela ser
/// montada, então não pode ser um Cubit escopado por rota.
class AdminSessionCubit extends Cubit<AdminSessionState> {
  AdminSessionCubit({AdminAuthRepository? repository})
    : _repository = repository,
      super(const AdminSessionSemAcesso());

  final AdminAuthRepository? _repository;

  /// Reabre a sessão guardada no navegador (GEOPRAG-187). Chamado uma vez,
  /// antes de o app aparecer.
  Future<void> restaurar() async {
    try {
      final conta = await _repository?.sessaoAtual();
      if (conta != null) emit(AdminSessionAutenticado(conta));
    } catch (e, stackTrace) {
      // Sem leitura do armazenamento, o portal segue sem sessão e pede o login.
      AppLogger.error('AdminSessionCubit.restaurar', e, stackTrace);
    }
  }

  void iniciarSessao(AdminAccount conta) =>
      emit(AdminSessionAutenticado(conta));

  /// Logout: volta a `SemAcesso` na hora (a UI não espera o armazenamento) e
  /// então apaga a sessão guardada (token e conta).
  Future<void> encerrarSessao() async {
    emit(const AdminSessionSemAcesso());
    try {
      await _repository?.logout();
    } catch (e, stackTrace) {
      AppLogger.error('AdminSessionCubit.encerrarSessao', e, stackTrace);
    }
  }

  /// A API já apagou o token (sessão expirada sem refresh): só falta voltar ao
  /// login.
  void sessaoPerdida() => emit(const AdminSessionSemAcesso());

  /// Esquema de permissões por capacidade (GEOPRAG-112) — consulta única
  /// usada pela UI (ex.: `GatedActionButton`) para decidir se uma ação deve
  /// aparecer habilitada. Sem sessão autenticada, nunca libera nada.
  bool podeExecutar(Capacidade capacidade) {
    final estado = state;
    if (estado is! AdminSessionAutenticado) return false;
    return capacidadesPorCargo[estado.conta.role]?.contains(capacidade) ??
        false;
  }

  /// Segunda camada da checagem de permissão (GEOPRAG-112): a UI já
  /// desabilita a ação via [podeExecutar], mas uma chamada direta a um
  /// método de domínio (deep link, atalho, bug de UI) não deve passar sem
  /// essa mesma checagem. Cubits de ação devem chamar isto antes de mutar
  /// estado.
  void garantirCapacidade(Capacidade capacidade) {
    if (!podeExecutar(capacidade)) {
      throw const OperacaoNaoPermitidaException(
        'Seu cargo não tem permissão para executar esta ação.',
      );
    }
  }
}
