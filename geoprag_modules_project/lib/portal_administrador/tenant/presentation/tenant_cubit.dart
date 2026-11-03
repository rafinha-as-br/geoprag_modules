import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/application/admin_portal_runtime.dart';
import '../../../src/features/tenant/domain/tenant_config.dart';
import 'tenant_state.dart';
import '../../../src/core/errors/app_error_messages.dart';
import '../../../src/core/errors/app_exceptions.dart';
import '../../../src/core/logging/app_logger.dart';
import '../../autenticacao/core/admin_account.dart';

/// Carrega a configuração do tenant (prefeitura) atual: tenta o cache local
/// primeiro (cold start offline) e depois busca/atualiza a partir do
/// `tenant_id`. Não há downloader de `.mbtiles` aqui — isso é exclusivo do
/// `aplicador_app` (ver `aplicador_app/tenant/presentation/tenant_cubit.dart`).
class AdminTenantCubit extends Cubit<AdminTenantState> {
  AdminTenantCubit(this._repository) : super(const AdminTenantInitial());

  final TenantRepository _repository;

  /// Carrega a configuração do tenant indicado pela sessão autenticada.
  ///
  /// O identificador não é escolhido pela interface: vem da resposta de login
  /// do servidor. Em homologação, a política do Portal também garante que a
  /// sessão pertence ao tenant isolado do piloto antes de consultar o cache.
  Future<void> loadForAccount(AdminAccount account) async {
    try {
      AdminPortalRuntime.atual.validarTenantDoPortal(account.tenantId);
    } on ArgumentError catch (error) {
      emit(AdminTenantError(error.message?.toString() ?? 'Tenant inválido.'));
      return;
    }
    await load(account.tenantId);
  }

  /// Remove a configuração atualmente exibida quando a sessão termina.
  ///
  /// O cache persistente continua sendo reaproveitado somente se o próximo
  /// login for do mesmo tenant; o estado em memória, porém, não pode manter a
  /// configuração de uma conta que acabou de sair.
  void limparSessao() => emit(const AdminTenantInitial());

  Future<void> load(String tenantId) async {
    final cached = await _repository.readCached();
    // O cache só vale para o mesmo tenant: o tenant agora vem do login (GEOPRAG-187)
    // e outro usuário não pode ver, nem por um instante, a config do anterior.
    if (cached != null && cached.tenantId == tenantId) {
      emit(AdminTenantReady(cached));
    }
    try {
      final config = await _repository.fetchByTenantId(tenantId);
      await _repository.cache(config);
      emit(AdminTenantReady(config));
    } on EntidadeNaoEncontradaException catch (e) {
      emit(AdminTenantError(e.mensagemAmigavel));
    } catch (e, stackTrace) {
      AppLogger.error('AdminTenantCubit.load', e, stackTrace);
      emit(AdminTenantError(AppErrorMessages.carregamentoGenerico));
    }
  }
}
