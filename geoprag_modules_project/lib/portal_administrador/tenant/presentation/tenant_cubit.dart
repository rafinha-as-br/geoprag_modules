import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/entities/tenant_config.dart';
import 'tenant_state.dart';

/// Carrega a configuração do tenant (prefeitura) atual: tenta o cache local
/// primeiro (cold start offline) e depois busca/atualiza a partir do
/// `tenant_id`. Não há downloader de `.mbtiles` aqui — isso é exclusivo do
/// `aplicador_app` (ver `aplicador_app/tenant/presentation/tenant_cubit.dart`).
class AdminTenantCubit extends Cubit<AdminTenantState> {
  AdminTenantCubit(this._repository) : super(const AdminTenantInitial());

  final TenantRepository _repository;

  Future<void> load(String tenantId) async {
    final cached = await _repository.readCached();
    if (cached != null) {
      emit(AdminTenantReady(cached));
    }
    try {
      final config = await _repository.fetchByTenantId(tenantId);
      await _repository.cache(config);
      emit(AdminTenantReady(config));
    } catch (e) {
      emit(AdminTenantError(e.toString()));
    }
  }
}
