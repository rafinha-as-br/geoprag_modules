import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/tenant_config.dart';
import 'tenant_state.dart';

/// Carrega a configuração do tenant (prefeitura) atual: tenta o cache local
/// primeiro (cold start offline) e depois busca/atualiza a partir do
/// `tenant_id`. Não há downloader de `.mbtiles` aqui — isso é exclusivo do
/// `aplicador_app` (ver `aplicador_app/tenant/presentation/tenant_cubit.dart`).
class TenantCubit extends Cubit<TenantState> {
  TenantCubit(this._repository) : super(const TenantInitial());

  final TenantRepository _repository;

  Future<void> load(String tenantId) async {
    final cached = await _repository.readCached();
    if (cached != null) {
      emit(TenantReady(cached));
    }
    try {
      final config = await _repository.fetchByTenantId(tenantId);
      await _repository.cache(config);
      emit(TenantReady(config));
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }
}
