import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/entities/tenant_config.dart';
import '../data/mbtiles_downloader.dart';
import 'tenant_state.dart';

/// Carrega a configuração do tenant (prefeitura) atual e provisiona o
/// download em background do pacote `.mbtiles` (via [MbtilesDownloader]),
/// emitindo o progresso em [TenantDownloading] antes de [TenantReady].
class TenantCubit extends Cubit<TenantState> {
  TenantCubit(this._repository, this._downloader)
    : super(const TenantInitial());

  final TenantRepository _repository;
  final MbtilesDownloader _downloader;

  Future<void> load(String tenantId) async {
    final cached = await _repository.readCached();
    if (cached != null) {
      emit(TenantReady(cached));
    }
    try {
      final config = await _repository.fetchByTenantId(tenantId);
      await for (final progress in _downloader.download(config.mbtilesUrl)) {
        emit(TenantDownloading(progress));
      }
      await _repository.cache(config);
      emit(TenantReady(config));
    } catch (e) {
      emit(TenantError('Não foi possível carregar os dados. Tente novamente.'));
    }
  }
}
