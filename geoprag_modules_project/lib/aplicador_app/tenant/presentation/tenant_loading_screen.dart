import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/widgets/geoprag_tenant_loading_screen.dart';
import 'tenant_cubit.dart';
import 'tenant_state.dart';

/// Tela exibida pelo guard de tenant do `go_router` enquanto o
/// [TenantCubit] ainda não emitiu [TenantReady] — inclui o progresso do
/// download do pacote `.mbtiles` em [TenantDownloading].
class TenantLoadingScreen extends StatelessWidget {
  const TenantLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TenantCubit, TenantState>(
      builder: (context, state) {
        return GeopragTenantLoadingScreen(
          isError: state is TenantError,
          errorMessage: state is TenantError ? state.message : null,
          progress: state is TenantDownloading ? state.progress : null,
        );
      },
    );
  }
}
