import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/widgets/geoprag_tenant_loading_screen.dart';
import 'tenant_cubit.dart';
import 'tenant_state.dart';

/// Tela exibida pelo guard de tenant do `go_router` enquanto o
/// [AdminTenantCubit] ainda não emitiu [AdminTenantReady].
class AdminTenantLoadingScreen extends StatelessWidget {
  const AdminTenantLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminTenantCubit, AdminTenantState>(
      builder: (context, state) {
        return GeopragTenantLoadingScreen(
          isError: state is AdminTenantError,
          errorMessage: state is AdminTenantError ? state.message : null,
        );
      },
    );
  }
}
