import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/entities/tenant_config.dart';
import 'tenant_state.dart';
import '../../../src/errors/app_error_messages.dart';
import '../../../src/errors/app_exceptions.dart';
import '../../../src/errors/app_logger.dart';

/// Carrega a configuração do tenant (prefeitura) atual: tenta o cache local
/// primeiro (cold start offline) e depois busca/atualiza a partir do
/// `tenant_id`. Não há downloader de `.mbtiles` aqui — isso é exclusivo do
/// `aplicador_app` (ver `aplicador_app/tenant/presentation/tenant_cubit.dart`).
class AdminTenantCubit extends Cubit<AdminTenantState> {
  AdminTenantCubit(this._repository) : super(const AdminTenantInitial());

  final TenantRepository _repository;

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
